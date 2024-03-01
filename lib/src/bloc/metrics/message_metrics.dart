import 'dart:async';
import 'package:carp_apps_package/apps.dart';
import 'package:carp_communication_package/communication.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/runtime/runtime.dart';
import 'package:flutter/material.dart';
import '../../sensing/sensing.dart';

class MessageMetrics extends ChangeNotifier {
  StreamSubscription<Measurement>? _subscription;

  // Singleton
  static final MessageMetrics _instance = MessageMetrics._internal();
  factory MessageMetrics() => _instance;
  MessageMetrics._internal();

  /// Get the instance of ScreenActivityMetrics
  static MessageMetrics get instance => _instance;

  /// Start listening to screen events from the measurements stream
  void startListening() {
    _subscription = Sensing().controller!.measurements
        .where((measurement) => measurement.data.format.toString() == CommunicationSamplingPackage.TEXT_MESSAGE_LOG)
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
    TextMessageLog textMessageLog = measurement.data as TextMessageLog;
    info("[MessageMetrics] Received data: ");

    for (var element in textMessageLog.textMessageLog) {
      info("Message from ${element.address}: ${element.body}");

      //todo: implement metrics calculation (when i'll figure out what to calculate xd)
    }
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