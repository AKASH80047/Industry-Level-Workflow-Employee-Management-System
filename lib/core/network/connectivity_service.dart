import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Stream of connection lists mapping to 6.x.x version of connectivity_plus
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;

  /// Check if the device is currently connected to any network (Wifi, Mobile, VPN, etc.)
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return _hasActiveConnection(results);
  }

  /// Helper to check if any active connection type exists in list
  bool _hasActiveConnection(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    
    // If it contains none, then there is no internet
    if (results.contains(ConnectivityResult.none)) {
      return false;
    }
    
    // Otherwise, we have some kind of connection
    return results.any((result) => 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet ||
      result == ConnectivityResult.vpn ||
      result == ConnectivityResult.other
    );
  }

  /// Exposes a stream of simplified boolean connectivity status
  Stream<bool> get connectivityStatusStream {
    return _connectivity.onConnectivityChanged.map((results) => _hasActiveConnection(results));
  }
}
