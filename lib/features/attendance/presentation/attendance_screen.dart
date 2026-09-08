import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/enrollment.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/theme/app_theme.dart';
import '../../events/presentation/event_details_screen.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  AttendanceUiState _ui = AttendanceUiState.notStarted;
  String? _message;
  bool _busy = false;

  Future<void> _mark() async {
    setState(() {
      _busy = true;
      _ui = AttendanceUiState.waitingForLocation;
      _message = 'Reading your GPS position…';
    });
    try {
      final fix = await ref.read(locationServiceProvider).currentPosition();
      setState(() {
        _ui = AttendanceUiState.verifying;
        _message = 'Verifying with the server…';
      });
      final result = await ref.read(eventRepositoryProvider).markAttendance(
            widget.eventId,
            latitude: fix.latitude,
            longitude: fix.longitude,
            accuracyMeters: fix.accuracyMeters,
          );
      setState(() {
        _ui = result.uiState;
        _message = result.message ?? _defaultMessage(result.uiState);
      });
    } catch (e) {
      setState(() {
        _ui = AttendanceUiState.rejected;
        _message = e.toString();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _defaultMessage(AttendanceUiState state) {
    switch (state) {
      case AttendanceUiState.verified:
        return 'Attendance verified.';
      case AttendanceUiState.outsideRadius:
        return 'Move closer to the meetup point.';
      case AttendanceUiState.windowNotOpen:
        return 'Attendance is not open yet.';
      case AttendanceUiState.windowClosed:
        return 'Attendance window closed.';
      case AttendanceUiState.flagged:
        return 'Attendance flagged for review.';
      case AttendanceUiState.rejected:
        return 'Attendance rejected.';
      default:
        return 'Checking attendance…';
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: eventAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (event) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(event.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                const Text(
                  'Attendance uses your location near the meetup point during the attendance window. GPS is a verification signal, not absolute proof of participation.',
                ),
                if (event.attendanceStartTime != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Window opens: ${event.attendanceStartTime!.toLocal()}',
                  ),
                ],
                if (event.attendanceEndTime != null)
                  Text('Window closes: ${event.attendanceEndTime!.toLocal()}'),
                const SizedBox(height: 24),
                Text(
                  'Status: ${_ui.name}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _ui == AttendanceUiState.verified
                          ? AppColors.success
                          : _ui == AttendanceUiState.outsideRadius
                              ? AppColors.clay
                              : AppColors.ink,
                    ),
                  ),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: _busy ? null : _mark,
                  child: Text(_busy ? 'Working…' : 'Share location & mark attendance'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
