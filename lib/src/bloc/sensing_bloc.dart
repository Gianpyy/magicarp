import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:magicarp/src/bloc/metrics/app_usage_metrics.dart';
import 'package:magicarp/src/bloc/metrics/message_metrics.dart';
import 'package:magicarp/src/bloc/metrics/mobility_metrics.dart';
import 'package:magicarp/src/bloc/metrics/screen_activity_metrics.dart';
import '../models/deployment_model.dart';
import '../models/device_model.dart';
import '../models/probe_model.dart';
import '../sensing/sensing.dart';


class SensingBLoC {
  static const String studyDeploymentIdKey = 'study_deployment_id';

  String? _studyDeploymentId;
  bool _useCached = true;
  bool _resumeSensingOnStartup = false;

  // Metrics classes
  final ScreenActivityMetrics _screenActivityMetrics = ScreenActivityMetrics.instance;
  final AppUsageMetrics _appUsageMetrics = AppUsageMetrics.instance;
  final MessageMetrics _messageMetrics = MessageMetrics.instance;
  final MobilityMetrics _mobilityMetrics = MobilityMetrics.instance;

  /// The [Sensing] layer used in the app.
  Sensing get sensing => Sensing();

  /// The study deployment id for the currently running deployment
  /// Returns the deployment id cached locally on the phone (if available)
  String? get studyDeploymentId => (_studyDeploymentId ??=
      Settings().preferences?.getString(studyDeploymentIdKey));

  /// Set the study deployment id for the currently running deployment
  /// This study deployment id wil be cached locally on the phone
  set studyDeploymentId(String? id) {
    assert(
      id != null,
      'Cannot set the study deployment id to null in Settings. '
      "Use the 'eraseStudyDeployment()' method to erase study deployment information."
    );
    _studyDeploymentId = id;
    Settings().preferences?.setString(studyDeploymentIdKey, id!);
  }

  /// Use the cached study deployment?
  bool get useCachedStudyDeployment => _useCached;

  /// Should sensing be automatically resumed on app startup?
  bool get resumeSensingOnStartup => _resumeSensingOnStartup;

  /// Erase all study deployment information cached locally on this phone.
  Future<void> eraseStudyDeployment() async {
    _studyDeploymentId = null;
    await Settings().preferences!.remove(studyDeploymentIdKey);
  }

  /// The [SmartphoneDeployment] deployed on this phone.
  SmartphoneDeployment? get deployment => Sensing().controller?.deployment;

  /// What kind of deployment are we running - local or CARP?
  DeploymentMode deploymentMode = DeploymentMode.local;

  /// The preferred format of the data to be uploaded according to
  /// [NameSpace]. Default using the [NameSpace.CARP].
  String dataFormat = NameSpace.CARP;

  StudyDeploymentModel? _model;

  /// The list of available app tasks for the user to address.
  List<UserTask> get tasks => AppTaskController().userTaskQueue;

  /// Get the study deployment model for this app.
  StudyDeploymentModel get studyDeploymentModel =>
      _model ??= StudyDeploymentModel(deployment!);

  /// Get a list of running probes
  Iterable<ProbeModel> get runningProbes =>
      Sensing().runningProbes.map((probe) => ProbeModel(probe));

  /// Get a list of available devices
  Iterable<DeviceModel> get availableDevices =>
      Sensing().availableDevices!.map((device) => DeviceModel(device));

  /// Get a list of running devices
  Iterable<DeviceModel> get connectedDevices =>
      Sensing().connectedDevices!.map((device) => DeviceModel(device));

  /// Initialize the BLoC
  Future<void> initialize({
    DeploymentMode deploymentMode = DeploymentMode.local,
    String dataFormat = NameSpace.CARP,
    bool useCachedStudyDeployment = false,
    bool resumeSensingOnStartup = false,
  }) async {
    await Settings().init();
    Settings().debugLevel = DebugLevel.debug;

    // Don't store the AppTask queue across app restart
    Settings().saveAppTaskQueue = false;

    this.deploymentMode = deploymentMode;
    this.dataFormat = dataFormat;
    _resumeSensingOnStartup = resumeSensingOnStartup;
    _useCached = useCachedStudyDeployment;

    info('$runtimeType initialized');
  }

  /// Connect to a [device] which is part of the [deployment].
  void connectToDevice(DeviceModel device) =>
      SmartPhoneClientManager().deviceController.devices[device.type!]!.connect();

  /// Start sensing
  void start() {
    SmartPhoneClientManager().notificationController?.createNotification(
      title: 'Sensing Started',
      body:
      'Data sampling is now running in the background. Click the STOP button to stop sampling again.',
    );
    SmartPhoneClientManager().start();
  }

  /// Stop sensing
  void stop() {
    SmartPhoneClientManager().notificationController?.createNotification(
      title: 'Sensing Stopped',
      body:
      'Sampling is stopped and no more data will be collected. Click the START button to restart sampling.',
    );
    SmartPhoneClientManager().stop();
  }

  /// Is sensing running, i.e. has the study executor has been resumed?
  bool get isRunning => (Sensing().controller != null) && Sensing().controller!.executor.state == ExecutorState.started;

  /// The instance of ScreenActivityMetrics
  ScreenActivityMetrics get screenActivityMetrics => _screenActivityMetrics;

  /// The instance of AppUsageMetrics
  AppUsageMetrics get appUsageMetrics => _appUsageMetrics;

  /// The instance of MessageMetrics
  MessageMetrics get messageMetrics => _messageMetrics;

  /// The instance of MobilityMetrics
  MobilityMetrics get mobilityMetrics => _mobilityMetrics;
}

final bloc = SensingBLoC();

/// How to deploy a study.
enum DeploymentMode {
  /// Use a local study protocol & deployment and store data locally in a file.
  local,

  /// Use the CARP production server to get the study deployment and store data.
  carpProduction,

  /// Use the CARP staging server to get the study deployment and store data.
  carpStaging,
}