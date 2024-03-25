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
        // You can put anything here (as long as it is a valid UUID), and this will be replaced with
        // the ID of the user uploading the protocol.
        ownerId: "979b408d-784e-4b1b-bb1e-ff9204e072f3",
        name: "Track something, hopefully this time will work for sure!",
        dataEndPoint: FileDataEndPoint(
            bufferSize: 500 * 1000,
            zip: false,
            encrypt: false,
            dataFormat: NameSpace.CARP
        ),
    );

    // Always add a participant role to the protocol
    const participant = 'Participant';
    protocol.participantRoles?.add(ParticipantRole(participant, false));

    // Define the primary device(s)
    var phone = Smartphone();
    protocol.addPrimaryDevice(phone);

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

    //!!!! TEST !!!!!

    // Add a background task that collects activity data from the phone
    protocol.addTaskControl(
        ImmediateTrigger(),
        BackgroundTask(measures: [
          Measure(type: ContextSamplingPackage.ACTIVITY),
        ]),
        phone);

    // Define the online location service and add it as a 'device'
    // LocationService locationService = LocationService(
    //   accuracy: GeolocationAccuracy.balanced,
    //   distance: 1,
    //   interval: const Duration(seconds: 10),
    // );
    // protocol.addConnectedDevice(locationService, phone);

    // Add a background task that continuously collects mobility
    // protocol.addTaskControl(
    //     ImmediateTrigger(),
    //     BackgroundTask(measures: [
    //       Measure(type: ContextSamplingPackage.MOBILITY),
    //     ]),
    //     locationService);


    // Define the online location service and add it as a 'connected device'
    final locationService = LocationService(
        accuracy: GeolocationAccuracy.high,
        distance: 10,
        interval: const Duration(minutes: 1));

    protocol.addConnectedDevice(locationService, phone);

    // Add a background task that collects location every 5 minutes
    protocol.addTaskControl(
        PeriodicTrigger(period: const Duration(minutes: 5)),
        BackgroundTask(measures: [
          (Measure(type: ContextSamplingPackage.CURRENT_LOCATION)),
        ]),
        locationService);

    // Add a background task that continuously collects location and mobility
    // patterns. Delays sampling by 5 minutes.
    protocol.addTaskControl(
        DelayedTrigger(delay: const Duration(minutes: 5)),
        BackgroundTask(measures: [
          Measure(type: ContextSamplingPackage.LOCATION),
          Measure(type: ContextSamplingPackage.MOBILITY)
        ]),
        locationService);

    // Add a background task that collects geofence events using DTU as the
    // center for the geofence.
    protocol.addTaskControl(
        ImmediateTrigger(),
        BackgroundTask()
          ..addMeasure(Measure(type: ContextSamplingPackage.GEOFENCE)
            ..overrideSamplingConfiguration = GeofenceSamplingConfiguration(
                name: 'DTU',
                center: GeoPosition(55.786025, 12.524159),
                dwell: const Duration(minutes: 15),
                radius: 10.0)),
        locationService);

    return protocol;
  }

  @override
  Future<bool> saveStudyProtocol(String id, SmartphoneStudyProtocol protocol) {
    // TODO: implement saveStudyProtocol
    throw UnimplementedError();
  }
}