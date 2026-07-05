import 'package:geolocator/geolocator.dart';

class GeofenceService {
  /// Calculates distance in meters between two geocoordinates using WGS84 ellipsoid
  double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Checks if the employee coordinates fall within the specified office boundary
  bool isWithinGeofence({
    required double userLatitude,
    required double userLongitude,
    required double officeLatitude,
    required double officeLongitude,
    required double allowedRadiusMeters,
  }) {
    final distance = calculateDistance(
      startLatitude: userLatitude,
      startLongitude: userLongitude,
      endLatitude: officeLatitude,
      endLongitude: officeLongitude,
    );
    return distance <= allowedRadiusMeters;
  }

  /// Verifies current device location telemetry
  Future<Position> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    // Fetch high accuracy coordinates
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
