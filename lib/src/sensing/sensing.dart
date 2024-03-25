import 'dart:developer';
import 'package:carp_apps_package/apps.dart';
import 'package:carp_communication_package/communication.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_serializable/carp_serializable.dart';
import 'package:magicarp/src/bloc/metrics/app_usage_metrics.dart';
import 'package:magicarp/src/bloc/metrics/message_metrics.dart';
import 'package:magicarp/src/bloc/metrics/mobility_metrics.dart';
import 'package:magicarp/src/sensing/protocol.dart';

import '../bloc/metrics/screen_activity_metrics.dart';
import '../bloc/sensing_bloc.dart';

/// This class implements the sensing layer.
///
/// Call [initialize] to setup a deployment.
///
/// Once initialized, the runtime [controller] can be used to
/// control the study execution (e.g., resume, pause, stop).
///
/// Collected data is available in the [measurements] stream.
///
/// Works as a singleton, and can be accessed by `Sensing()`.
class Sensing {
  static final Sensing _instance = Sensing._();
  StudyDeploymentStatus? _status;
  SmartphoneDeploymentController? _controller;

  DeploymentService? deploymentService;
  SmartPhoneClientManager? client;

  /// The study running on this phone
  Study? study;

  /// Get the latest status of the study deployment.
  StudyDeploymentStatus? get status => _status;

  /// The role name of this device in the deployed study
  String? get deviceRolename => _status?.primaryDeviceStatus?.device.roleName;

  /// The study runtime controller for this deployment
  SmartphoneDeploymentController? get controller => (study != null)
      ? SmartPhoneClientManager().getStudyRuntime(study!)
      : null;

  /// The stream of all sampled measurements.
  Stream<Measurement> get measurements =>
      controller?.measurements ?? const Stream.empty();

  /// The list of running - i.e. used - probes in this study.
  List<Probe> get runningProbes =>
      (_controller != null) ? _controller!.executor.probes : [];

  /// The list of available devices.
  List<DeviceManager>? get availableDevices =>
      SmartPhoneClientManager().deviceController.devices.values.toList();

  /// The list of connected devices.
  List<DeviceManager>? get connectedDevices =>
      SmartPhoneClientManager().deviceController.connectedDevices.toList();

  /// The singleton sensing instance
  factory Sensing() => _instance;

  // Create and register external sampling packages
  Sensing._() : super() {
    CarpMobileSensing.ensureInitialized();

    // Create and register external sampling packages
    SamplingPackageRegistry().register(ContextSamplingPackage());
    SamplingPackageRegistry().register(AppsSamplingPackage());
    SamplingPackageRegistry().register(CommunicationSamplingPackage());
  }

  /// Initialize and set up sensing
  Future<void> initialize() async {
    info("Initializing $runtimeType.");
    Settings().debugLevel = DebugLevel.debug;

    // Get the local deployment service
    deploymentService = SmartphoneDeploymentService();

    // Get the protocol from the local study protocol manager
    // Note that the study id is not used
    StudyProtocol protocol = await LocalStudyProtocolManager().getStudyProtocol('ignored');

    // Deploy this protocol using the on-phone deployment service
    // Reuse the study deployment id, if this is stored on the phone
    _status = await SmartphoneDeploymentService().createStudyDeployment(
      protocol,
      [],
      bloc.studyDeploymentId,
    );

    // Save the correct deployment id on the phone for later use
    bloc.studyDeploymentId = _status!.studyDeploymentId;

    // Register the CARP data manager for uploading data back to CARP.
    // This is needed in both LOCAL and CARP deployments, since a local study
    // protocol may still upload to CARP
    // DataManagerRegistry().register(CarpDataManagerFactory());

    // Create and configure a client manager for this phone
    client = SmartPhoneClientManager();
    await client?.configure(
      deviceController: DeviceController(),
    );

    // Define the study and add it to the client.
    study = Study(
      bloc.studyDeploymentId!,
      deviceRolename!,
    );
    await client?.addStudy(study!.studyDeploymentId, study!.deviceRoleName);

    // Get the study controller and try to deploy the study.
    //
    // Note that if the study has already been deployed on this phone
    // it has been cached locally in a file and the local cache will
    // be used pr. default.
    // If not deployed before (i.e., cached) the study deployment will be
    // fetched from the deployment service.
    _controller = client?.getStudyRuntime(study!);
    await controller?.tryDeployment(useCached: bloc.useCachedStudyDeployment);

    // Configure the controller
    await controller?.configure();

    // Start sampling
    controller?.start(bloc.resumeSensingOnStartup);

    // Listen to the data stream and print the data as json to the debug console
    client?.measurements.listen((measurement) => log("${toJsonString(measurement)}\n"));

    info('$runtimeType initialized');

    // Initialize metrics
    _initializeMetrics();
  }

  void _initializeMetrics() {
    // Initialize Screen Activity metrics
    ScreenActivityMetrics screenActivityMetrics = bloc.screenActivityMetrics;
    screenActivityMetrics.startListening();
    info("ScreenActivityMetrics initialized");

    // Initialize App Usage metrics
    AppUsageMetrics appUsageMetrics = bloc.appUsageMetrics;
    appUsageMetrics.startListening();
    info("AppUsageMetrics initialized");

    // Initialize MessageMetrics
    MessageMetrics messageMetrics = bloc.messageMetrics;
    messageMetrics.startListening();
    info("MessageMetrics initialized");

    // Initialize MobilityMetrics
    MobilityMetrics mobilityMetrics = bloc.mobilityMetrics;
    mobilityMetrics.startListening();
    info("MobilityMetrics initialized");
  }
}