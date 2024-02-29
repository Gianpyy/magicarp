import 'dart:async';
import 'package:carp_apps_package/apps.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/runtime/runtime.dart';
import 'package:flutter/material.dart';
import '../../sensing/sensing.dart';

class AppUsageMetrics extends ChangeNotifier {
  StreamSubscription<Measurement>? _subscription;

  // Singleton
  static final AppUsageMetrics _instance = AppUsageMetrics._internal();
  factory AppUsageMetrics() => _instance;
  AppUsageMetrics._internal();

  /// Get the instance of ScreenActivityMetrics
  static AppUsageMetrics get instance => _instance;

  /// Start listening to screen events from the measurements stream
  void startListening() {
    _subscription = Sensing().controller!.measurements
        .where((measurement) => measurement.data.format.toString() == AppsSamplingPackage.APP_USAGE)
        .listen((data) {
          processData(data);
        }, onDone: () {
          handleDone();
        }, onError: (error) {
          handleError(error);
        });
  }

  /// Process the data received by the measurements stream
  void processData(Measurement measurement) {
    AppUsage appUsage = measurement.data as AppUsage;
    info("Received data:\n");
    appUsage.usage.forEach((key, appUsageInfo) {
      int duration = appUsageInfo.usage.inMinutes;
      info("App: ${appUsageInfo.appName}, Usage(in minutes): $duration");
    });
    //todo: implement metrics calculation (when i'll figure out what to calculate xd)
  }

  /// Handle when the stream is done
  void handleDone() {
    info("Stream done.");
  }

  /// Handle errors in the data stream
  void handleError(error) {
    info("Error: $error");
  }

  /// Stop listening to the stream
  void stopListening() {
    _subscription?.cancel();
  }
}