import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/ride_buffer_store.dart';
import '../../../shared/models/ride.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/theme/app_theme.dart';

final routeGeometryProvider =
    FutureProvider.autoDispose.family<RouteGeometry, String>((ref, trailId) {
  return ref.watch(routeRepositoryProvider).loadGeometry(trailId);
});

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key, required this.trailId});

  final String trailId;

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  GoogleMapController? _mapController;
  final _bufferStore = RideBufferStore();
  LocalRideBuffer? _buffer;
  RideStatus _status = RideStatus.active;
  SyncState _syncState = SyncState.recorded;
  StreamSubscription? _gpsSub;
  LatLng? _current;
  DateTime? _startedAt;
  double _distanceMeters = 0;
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _gpsSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _startRide() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final fix = await ref.read(locationServiceProvider).currentPosition();
      final ride = await ref.read(rideRepositoryProvider).startRide(
            trailId: widget.trailId,
            latitude: fix.latitude,
            longitude: fix.longitude,
          );
      final buffer = await _bufferStore.create(widget.trailId);
      buffer.remoteRideId = ride.id;
      await _bufferStore.upsert(buffer);
      _buffer = buffer;
      _startedAt = DateTime.now();
      _status = RideStatus.active;
      _current = LatLng(fix.latitude, fix.longitude);
      _gpsSub = ref.read(locationServiceProvider).watchPosition().listen((pos) {
        final next = LatLng(pos.latitude, pos.longitude);
        if (_current != null) {
          _distanceMeters += Geolocator.distanceBetween(
            _current!.latitude,
            _current!.longitude,
            next.latitude,
            next.longitude,
          );
        }
        _current = next;
        _buffer?.samples.add(
          GpsSample(
            latitude: pos.latitude,
            longitude: pos.longitude,
            accuracyMeters: pos.accuracyMeters,
            timestamp: pos.timestamp,
          ),
        );
        _buffer?.distanceMeters = _distanceMeters;
        _buffer?.syncState = SyncState.recorded;
        if (_buffer != null) {
          _bufferStore.upsert(_buffer!);
        }
        if (_status == RideStatus.active && _mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLng(next));
        }
        if (mounted) setState(() {});
        _maybeSync();
      });
      setState(() => _message = 'Ride active · Recorded locally');
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _maybeSync() async {
    final buffer = _buffer;
    final rideId = buffer?.remoteRideId;
    if (buffer == null || rideId == null || buffer.samples.isEmpty) return;
    if (buffer.samples.length % 10 != 0) return;
    try {
      final batch = buffer.samples
          .map((e) => e.toJson())
          .toList(growable: false);
      await ref.read(rideRepositoryProvider).syncTrackPoints(
            rideId: rideId,
            points: batch,
          );
      buffer.syncState = SyncState.synced;
      _syncState = SyncState.synced;
      await _bufferStore.upsert(buffer);
      if (mounted) setState(() {});
    } catch (_) {
      // Keep recorded locally; sync later.
    }
  }

  Future<void> _complete() async {
    final buffer = _buffer;
    final rideId = buffer?.remoteRideId;
    if (rideId == null || _current == null) return;
    setState(() {
      _busy = true;
      _message = 'Uploading ride…';
    });
    try {
      await _maybeSync();
      setState(() => _message = 'Verifying route…');
      final duration = _startedAt == null
          ? 0
          : DateTime.now().difference(_startedAt!).inSeconds;
      final result = await ref.read(rideRepositoryProvider).completeRide(
            rideId: rideId,
            latitude: _current!.latitude,
            longitude: _current!.longitude,
            distanceMeters: _distanceMeters,
            durationSeconds: duration,
      );
      _gpsSub?.cancel();
      buffer?.syncState =
          result.verified ? SyncState.verified : SyncState.verificationFailed;
      if (buffer != null) await _bufferStore.upsert(buffer);
      if (!mounted) return;
      context.go('/rides/summary', extra: {
        'verified': result.verified,
        'message': result.message,
        'familiarityLevel': result.familiarityLevel,
      });
    } catch (e) {
      setState(() => _message = 'Ride upload failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final geometryAsync = ref.watch(routeGeometryProvider(widget.trailId));
    final elapsed = _startedAt == null
        ? '00:00:00'
        : _formatDuration(DateTime.now().difference(_startedAt!));

    return Scaffold(
      backgroundColor: AppColors.night,
      body: geometryAsync.when(
        loading: () => const LoadingView(message: 'Loading authorized route…'),
        error: (e, _) => ErrorView(
          message: e.toString().contains('403') || e.toString().contains('not')
              ? 'Route data unavailable. Access may not be unlocked.'
              : e.toString(),
          onRetry: () => ref.invalidate(routeGeometryProvider(widget.trailId)),
        ),
        data: (geometry) {
          final polyline = Polyline(
            polylineId: const PolylineId('route'),
            color: AppColors.ember,
            width: 5,
            points: geometry.points
                .map((p) => LatLng(p.latitude, p.longitude))
                .toList(),
          );
          final start = geometry.start ?? geometry.points.first;
          final initial = CameraPosition(
            target: LatLng(start.latitude, start.longitude),
            zoom: 13,
          );
          return Column(
            children: [
              Container(
                width: double.infinity,
                color: AppColors.forest,
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.paddingOf(context).top + 12,
                  20,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Trail ride',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 8, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'GPS ACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _HudStat(label: 'Elapsed time', value: elapsed),
                        _HudStat(
                          label: 'Distance covered',
                          value:
                              '${(_distanceMeters / 1000).toStringAsFixed(1)} km',
                        ),
                        _HudStat(
                          label: 'Sync',
                          value: _syncState.name.toUpperCase(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: initial,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.hybrid,
                  polylines: {polyline},
                  markers: {
                    if (geometry.start != null)
                      Marker(
                        markerId: const MarkerId('start'),
                        position: LatLng(
                          geometry.start!.latitude,
                          geometry.start!.longitude,
                        ),
                      ),
                    if (geometry.end != null)
                      Marker(
                        markerId: const MarkerId('end'),
                        position: LatLng(
                          geometry.end!.latitude,
                          geometry.end!.longitude,
                        ),
                      ),
                  },
                  onMapCreated: (controller) => _mapController = controller,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.nightElevated,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SafeArea(
                  top: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_message != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _message!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      if (_buffer == null)
                        ElevatedButton(
                          onPressed: _busy ? null : _startRide,
                          child: Text(_busy ? 'Starting…' : 'Start ride'),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.ember,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _status = _status == RideStatus.paused
                                        ? RideStatus.active
                                        : RideStatus.paused;
                                  });
                                },
                                child: Text(
                                  _status == RideStatus.paused
                                      ? 'Resume Ride'
                                      : 'Pause Ride',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.danger,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _busy ? null : _complete,
                                child: Text(
                                  _busy ? 'Finishing…' : 'End Ride',
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _HudStat extends StatelessWidget {
  const _HudStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
