import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Checks the current location permission status
  Future<PermissionStatus> locationStatus() async {
    return await Permission.locationWhenInUse.status;
  }

  /// Requests location permission
  Future<PermissionStatus> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status;
  }

  /// Checks the current camera permission status
  Future<PermissionStatus> cameraStatus() async {
    return await Permission.camera.status;
  }

  /// Requests camera permission
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// Check if location services are enabled globally (GPS toggled on)
  Future<bool> isLocationServiceEnabled() async {
    return await Permission.location.serviceStatus.isEnabled;
  }

  /// Opens the device settings page for this app
  Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Helper to verify both GPS enabled and location permission granted
  Future<bool> hasLocationAccess() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final status = await locationStatus();
    return status.isGranted;
  }

  /// Helper to verify camera permission is granted
  Future<bool> hasCameraAccess() async {
    final status = await cameraStatus();
    return status.isGranted;
  }
}
