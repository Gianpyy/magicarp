import 'package:carp_audio_package/media.dart';
import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';

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
        studyDescription: StudyDescription(
            title: 'magicarp',
            description: "This study protocol aims to continuously monitor the "
                "daily activities and behaviors of patients using smartphone "
                "sensors. The data collected will help assess behavioral "
                "patterns and potential health risks, with the goal of "
                "detecting early signs of relapse or changes in mental health. "
                "The study ensures the use of passive sensing to minimize "
                "interference with the patient's daily life, while providing "
                "clinicians with valuable insights for timely intervention.",
            purpose: 'Track patient data'
        )
    );

    // Define the data end-point
    //protocol.dataEndPoint = SQLiteDataEndPoint();
    protocol.dataEndPoint = FileDataEndPoint(
        bufferSize: 15000 * 1000,
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

    // Add an task that immediately starts collecting noise.
    protocol.addTaskControl(
        ImmediateTrigger(),
        BackgroundTask(
          name: "Ambient noise",
          measures: [
            Measure(type: MediaSamplingPackage.NOISE),
          ]),
        phone
    );

    // Sample an audio recording
    var audioTask = BackgroundTask(
      name: "Audio",
      measures: [
        Measure(type: MediaSamplingPackage.AUDIO),
      ]);

    // Start the audio task after 20 secs and stop it after 10 hours
    protocol
      ..addTaskControl(
        DelayedTrigger(delay: const Duration(seconds: 20)),
        audioTask,
        phone,
        Control.Start,
      )
      ..addTaskControl(
        DelayedTrigger(delay: const Duration(hours: 1)),
        audioTask,
        phone,
        Control.Stop,
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
        locationService
    );

    return protocol;
  }

  @override
  Future<bool> saveStudyProtocol(String id, SmartphoneStudyProtocol protocol) {
    // TODO: implement saveStudyProtocol
    throw UnimplementedError();
  }
}