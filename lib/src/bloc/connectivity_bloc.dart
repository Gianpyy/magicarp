import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../sensing/sensing.dart';

/// A class that handles the state of the network on the phone
/// and sends data to the server when connected to WiFi
class ConnectivityBloC {

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
      log("[INFO] Connected to WiFi, sending data to server");
      _startSendingDataPeriodically();
    } else {
      log("[INFO] Not connected to WiFi, stopping sending data to server");
      _stopSendingData();
    }
  }

  /// Starts sending data periodically while connected to WiFi
  void _startSendingDataPeriodically() {
    // Send data in 30 seconds intervals
    _dataSendTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) async {
      await Sensing().sendDataToServer();
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
        log("[INFO] Sending remaining data to server");
        await Sensing().sendDataToServer();
      } else {
        log("[INFO] No WiFi connection, remaining data will be lost :(");
      }
    }

    // Cancel the connectivity subscription
    _subscription?.cancel();

    // Stop the timer
    _stopSendingData();
  }
}

final connectivityBloc = ConnectivityBloC();