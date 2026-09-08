import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../errors/app_exception.dart';

class LocationFix {
  const LocationFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;
}

class LocationService {
  Future<bool> ensureLocationPermission({bool background = false}) async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }
    if (!status.isGranted) return false;

    if (background) {
      var bg = await Permission.locationAlways.status;
      if (!bg.isGranted) {
        bg = await Permission.locationAlways.request();
      }
      return bg.isGranted || status.isGranted;
    }
    return true;
  }

  Future<LocationFix> currentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const AppException(
        'Location services are off. Enable GPS to continue.',
      );
    }
    final permission = await ensureLocationPermission();
    if (!permission) {
      throw const AppException(
        'Location permission is required for attendance and navigation.',
      );
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    return LocationFix(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracyMeters: pos.accuracy,
      timestamp: pos.timestamp,
    );
  }

  Stream<LocationFix> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).map(
      (pos) => LocationFix(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracyMeters: pos.accuracy,
        timestamp: pos.timestamp,
      ),
    );
  }
}
