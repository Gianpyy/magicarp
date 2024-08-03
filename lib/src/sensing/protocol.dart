import 'package:carp_apps_package/apps.dart';
import 'package:carp_communication_package/communication.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_survey_package/survey.dart';
import 'package:magicarp/src/sensing/surveys.dart';

/// This class configures a [SmartphoneStudyProtocol] with [TriggerConfiguration]s, [TaskControl]s and [Measure]s
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
        name: "Track something, hopefully this time the app will stay opened in background!",
    );

    // Define the data end-point
    //protocol.dataEndPoint = SQLiteDataEndPoint();
    protocol.dataEndPoint = FileDataEndPoint(
        bufferSize: 500 * 1000,
        zip: false,
        encrypt: false,
        dataFormat: NameSpace.CARP,
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

    // Add a background task that continuously collects screen activity
    protocol.addTaskControl(
      ImmediateTrigger(),
      BackgroundTask(
        name: "Screen events",
        measures: [
          Measure(type: DeviceSamplingPackage.SCREEN_EVENT),
      ]),
      phone,
    );

    // Add a background task that continuously collects ambient light
    protocol.addTaskControl(
      ImmediateTrigger(),
      BackgroundTask(
          name: "Light",
          measures: [
            Measure(type: SensorSamplingPackage.AMBIENT_LIGHT),
          ]),
      phone,
    );

    // Add a background task that continuously collects acceleration features
    protocol.addTaskControl(
      ImmediateTrigger(),
      BackgroundTask(
          name: "Acceleration features",
          measures: [
            Measure(type: SensorSamplingPackage.ACCELERATION_FEATURES),
          ]),
      phone,
    );


    // Define the online location service and add it as a 'connected device'
    final locationService = LocationService();
    protocol.addConnectedDevice(locationService, phone);

    // Add a background task that continuously collects location
    protocol.addTaskControl(
        ImmediateTrigger(),
        BackgroundTask(
          name: "Location",
          measures: [
            Measure(type: ContextSamplingPackage.LOCATION),
        ]),
        locationService);

    return protocol;
  }

  @override
  Future<bool> saveStudyProtocol(String id, SmartphoneStudyProtocol protocol) {
    // TODO: implement saveStudyProtocol
    throw UnimplementedError();
  }
}