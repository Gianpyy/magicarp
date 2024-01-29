import 'package:carp_apps_package/apps.dart';
import 'package:carp_communication_package/communication.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';

/// This class configures a [SmartphoneStudyProtocol] with [Trigger]s, [TaskControl]s and [Measure]s
class LocalStudyProtocolManager implements StudyProtocolManager {
  @override
  Future<void> initialize() async {}

  /// Create a new CAMS study protocol
  @override
  Future<SmartphoneStudyProtocol> getStudyProtocol(String id) async {

    /// Create a study protocol with a [FileDataEndPoint] that uses the Open mHealth data format
    SmartphoneStudyProtocol protocol = SmartphoneStudyProtocol(
        ownerId: "Gianpy",
        name: "Track something",
        dataEndPoint: FileDataEndPoint(
            bufferSize: 500 * 1000,
            zip: false,
            encrypt: false,
            dataFormat: NameSpace.OMH
        ),
    );

    // Define which devices are used for data collection
    // In this case, it's only this [Smartphone]
    var phone = Smartphone();
    protocol.addPrimaryDevice(phone);

    // Define the online location service and add it as a 'connected device'
    final locationService = LocationService(
        accuracy: GeolocationAccuracy.high,
        distance: 10,
        interval: const Duration(minutes: 1)
    );
    protocol.addConnectedDevice(locationService, phone);


    /*
     * The following section contains the configuration for various tasks
     * utilized in data collection.
     */

    // Collect device info only once, when this study is deployed.
    protocol.addTaskControl(
      OneTimeTrigger(),
      BackgroundTask(
          measures: [
            Measure(type: DeviceSamplingPackage.DEVICE_INFORMATION),
          ]),
      phone,
    );

    // Collect data about the GPS location every 10 minutes since the start of the measuring
    protocol.addTaskControl(
        PeriodicTrigger(period: const Duration(minutes: 10)),
        BackgroundTask(measures: [
          (Measure(type: ContextSamplingPackage.CURRENT_LOCATION)),
        ]),
        locationService,
    );

    // Automatically collect step count, screen activity,
    // Sampling is delayed by 10 seconds.
    protocol.addTaskControl(
      DelayedTrigger(delay: const Duration(seconds: 10)),
      BackgroundTask(measures: [
        Measure(type: SensorSamplingPackage.STEP_COUNT),
        Measure(type: DeviceSamplingPackage.SCREEN_EVENT),
      ]),
      phone,
    );

    // Collect data about the app usage, phone calls and text messages
    // Sampling is done 1 hour(s) after the study has begun
    protocol.addTaskControl(
        DelayedTrigger(delay: const Duration(hours: 1)),
        BackgroundTask(measures: [
          Measure(type: AppsSamplingPackage.APP_USAGE),
          Measure(type: CommunicationSamplingPackage.PHONE_LOG),
          Measure(type: CommunicationSamplingPackage.TEXT_MESSAGE_LOG),
        ]),
        phone,
    );

    return protocol;
  }

  @override
  Future<bool> saveStudyProtocol(String id, SmartphoneStudyProtocol protocol) {
    // TODO: implement saveStudyProtocol
    throw UnimplementedError();
  }
}