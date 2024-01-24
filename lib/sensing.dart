import 'dart:developer';
import 'package:carp_apps_package/apps.dart';
import 'package:carp_communication_package/communication.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_serializable/carp_serializable.dart';
import 'package:magicarp/protocol.dart';

/// This class handles sensing logic
class Sensing {
  SmartPhoneClientManager? client;
  Study? study;

  /// Initialize sensing
  Future<void> init() async {
    Settings().debugLevel = DebugLevel.debug;

    // Get the local protocol
    StudyProtocol protocol = await LocalStudyProtocolManager().getStudyProtocol('ignored');

    // Create and configure a client manager for this phone
    client = SmartPhoneClientManager();
    await client?.configure();

    // Add external packages to the SamplingPackageRegistry
    SamplingPackageRegistry().register(ContextSamplingPackage());
    SamplingPackageRegistry().register(AppsSamplingPackage());
    SamplingPackageRegistry().register(CommunicationSamplingPackage());

    // Create a study based on the protocol
    study = await client?.addStudyProtocol(protocol);

    // Start sampling
    client?.start();

    // Listen to the data stream and print the data as json
    client?.measurements.listen((measurement) => log("${toJsonString(measurement)}\n"));
  }

  /// Is sensing running?
  bool get isRunning => (client != null) &&  client!.state == ClientManagerState.started;

  /// Status of sensing.
  ClientManagerState? get status => client?.state;

  /// Resume sensing
  void resume() async => client?.start();

  /// Dispose the entire deployment.
  void dispose() async => client?.dispose();

  /// Stop sensing.
  void stop() async => client?.stop();
}