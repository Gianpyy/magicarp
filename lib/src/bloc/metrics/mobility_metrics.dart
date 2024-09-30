import 'dart:async';
import 'dart:developer';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:flutter/material.dart';
import '../sensing_bloc.dart';

class MobilityMetrics extends ChangeNotifier {
  StreamSubscription<Measurement>? _subscription;

  // Mobility metrics
  int? _numberOfPlaces = 0;
  double? _locationVariance = 0.0;
  double? _entropy = 0.0;
  double? _normalizedEntropy = 0.0;
  double? _homeStay = 0.0;
  double? _distanceTraveled = 0.0;

  // Singleton
  static final MobilityMetrics _instance = MobilityMetrics._internal();
  factory MobilityMetrics() => _instance;
  MobilityMetrics._internal();

  /// Get the instance of ScreenActivityMetrics
  static MobilityMetrics get instance => _instance;

  /// Start listening to screen events from the measurements stream
  // void startListening() {
  //   _subscription = Sensing().controller!.measurements
  //       .where((measurement) => measurement.data.format.toString() == ContextSamplingPackage.MOBILITY)
  //       .listen((data) {
  //     processData(data);
  //   }, onDone: () {
  //     handleDone();
  //   }, onError: (error) {
  //     handleError(error);
  //   });
  // }

  /// Start listening to screen events from the measurements stream
  void startListening() {
    _subscription = sensingBloc.sensing.controller!.measurements
        .where((measurement) => measurement.data.format.toString() == ContextSamplingPackage.MOBILITY)
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
    log("[MobilityMetrics] Received data: $measurement");

    Mobility mobility = measurement as Mobility;

    // Update the values calculated by the mobility plugin
    _numberOfPlaces = mobility.numberOfPlaces;
    _locationVariance = mobility.locationVariance;
    _entropy = mobility.entropy;
    _normalizedEntropy = mobility.normalizedEntropy;
    _homeStay = mobility.homeStay;
    _distanceTraveled = mobility.distanceTraveled;

    // Notify listeners about changes in data
    notifyListeners();
  }

  /// Handle when the stream is done
  void handleDone() {
    log("Stream done.");
  }

  /// Handle errors in the data stream
  void handleError(error) {
    log("Error: $error");
  }

  /// Stop listening to the stream
  void stopListening() {
    _subscription?.cancel();
  }

  /// The distance traveled on the current day, in meters
  double? get distanceTraveled => _distanceTraveled;

  /// The value of home stay on the current day
  /// normalized in a value between 0 and 1
  double? get homeStay => _homeStay;

  /// The location entropy value on the current day
  /// normalized in a value between 0 and 1
  double? get normalizedEntropy => _normalizedEntropy;

  /// The location entropy value on the current day
  double? get entropy => _entropy;

  /// The location variance on the current day
  double? get locationVariance => _locationVariance;

  /// The number of places visited on the current day
  int? get numberOfPlaces => _numberOfPlaces;

  /// The date and time of the last time this measure was collected
  DateTime? get lastTime => MobilitySamplingConfiguration().lastTime;
}