import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import '../models/deployment_model.dart';
import '../models/device_model.dart';
import '../models/probe_model.dart';
import '../sensing/sensing.dart';


class SensingBLoC {
  static const String studyDeploymentIdKey = 'study_deployment_id';

  String? _studyDeploymentId;
  bool _useCached = true;
  bool _resumeSensingOnStartup = false;

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

  /// Get the study deployment model for this app.
  StudyDeploymentModel get studyDeploymentModel =>
      _model ??= StudyDeploymentModel(deployment!);

  /// Get a list of running probes
  Iterable<ProbeModel> get runningProbes =>
      Sensing().runningProbes.map((probe) => ProbeModel(probe));

  /// Get a list of running devices
  Iterable<DeviceModel> get availableDevices =>
      Sensing().availableDevices!.map((device) => DeviceModel(device));

  /// Initialize the BLoC
  Future<void> initialize({
    DeploymentMode deploymentMode = DeploymentMode.local,
    String dataFormat = NameSpace.OMH,
    bool useCachedStudyDeployment = true,
    bool resumeSensingOnStartup = false,
  }) async {
    await Settings().init();
    Settings().debugLevel = DebugLevel.debug;
    this.deploymentMode = deploymentMode;
    this.dataFormat = dataFormat;
    _resumeSensingOnStartup = resumeSensingOnStartup;
    _useCached = useCachedStudyDeployment;

    info('$runtimeType initialized');
  }

  /// Connect to a [device] which is part of the [deployment].
  void connectToDevice(DeviceModel device) =>
      Sensing().client?.deviceController.devices[device.type!]!.connect();

  /// Resume sensing
  void resume() async => Sensing().controller?.executor.start();

  /// Stop sensing
  void stop() async => Sensing().controller?.executor.stop();

  /// Is sensing running, i.e. has the study executor has been resumed?
  bool get isRunning => (Sensing().controller != null) && Sensing().controller!.executor.state == ExecutorState.started;
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