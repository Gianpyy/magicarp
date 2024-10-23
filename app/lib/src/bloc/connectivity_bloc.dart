import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../sensing/sensing.dart';

/// A class that handles the state of the network on the phone
/// and sends data to the server when connected to WiFi
class ConnectivityBLoC {

  Timer? _dataSendTimer;
  StreamSubscription<List<ConnectivityResult>>? _subscription;


  /// Initialize the BLoC
  Future<void> initialize() async {
    // Check initial connectivity status
    _checkInitialConnectivity();

    // Listen to connectivity changes on the phone
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      _handleConnectivityChange(result);
    });
  }

  /// Checks the initial connectivity status
  Future<void> _checkInitialConnectivity() async {
    final List<ConnectivityResult> result = await (Connectivity().checkConnectivity());
    _handleConnectivityChange(result);
  }

  /// Handle connectivity changes
  void _handleConnectivityChange(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.wifi)) {
      log("[INFO] Connected to WiFi");
      if (await _hasInternetAccess()) {
        log("[INFO] WiFi has internet access, sending data to server");
        _startSendingDataPeriodically();
      } else {
        log("[INFO] WiFi has no access to the internet");
      }
    } else {
      log("[INFO] Not connected to WiFi, stopping sending data to server");
      _stopSendingData();
    }
  }

  /// Check if the WiFi connection has internet access
  Future<bool> _hasInternetAccess() async {
    // Check for connectivity changes
    final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      try {
        // Make a GET request to Google.com to see if there's internet access
        final result = await http.get(Uri.parse("https://www.google.com")).timeout(const Duration(seconds: 5));
        if (result.statusCode == 200) {
          return true; // Connected to the internet
        } else {
          return false; // No connection or HTTP error
        }
      } on SocketException catch (_) {
        return false; // No internet access
      }
    } else {
      return false; // No WiFi connection
    }
  }

  /// Starts sending data periodically while connected to WiFi
  void _startSendingDataPeriodically() {
    // Send data in 30 seconds intervals
    _dataSendTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) async {
      if (await _hasInternetAccess()) {
        log("[INFO] WiFi has internet access, sending data to server");
        await Sensing().sendDataToServer();
      } else {
        log("[INFO] WiFi has no access to the internet");
      }
    });
  }

  /// Stops sending data periodically
  void _stopSendingData() {
    _dataSendTimer?.cancel();
    _dataSendTimer = null;
  }

  void dispose() async {
    // Send remaining data
    if (!Sensing().isBufferEmpty) {
      List<ConnectivityResult> result = await (Connectivity().checkConnectivity());

      if (result.contains(ConnectivityResult.wifi)) {
        if (await _hasInternetAccess()){
          log("[INFO] Sending remaining data to server");
          await Sensing().sendDataToServer();
        } else {
          log("[INFO] WiFi has no access to the internet, remaining data wil be lost");
        }
      } else {
        log("[INFO] No WiFi connection, remaining data will be lost");
      }
    }

    // Cancel the connectivity subscription
    _subscription?.cancel();

    // Stop the timer
    _stopSendingData();
  }
}

final connectivityBloc = ConnectivityBLoC();