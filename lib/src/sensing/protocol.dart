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
        bufferSize: 1500 * 1000,
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
          //Measure(type: CommunicationSamplingPackage.TEXT_MESSAGE_LOG),
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
    final locationService = LocationService();
    protocol.addConnectedDevice(locationService, phone);

    // Add a background task that collects location on a regular basis
    protocol.addTaskControl(
        PeriodicTrigger(period: const Duration(minutes: 5)),
        BackgroundTask(measures: [
          (Measure(type: ContextSamplingPackage.CURRENT_LOCATION)),
        ]),
        locationService);

    // Add a background task that continuously collects location and mobility
    protocol.addTaskControl(
        ImmediateTrigger(),
        BackgroundTask(measures: [
          Measure(type: ContextSamplingPackage.LOCATION),
          Measure(type: ContextSamplingPackage.MOBILITY)
        ]),
        locationService);


    // Collect demographic 10 minutes after the study starts
    protocol.addTaskControl(
        DelayedTrigger(delay: const Duration(minutes: 10)),
        RPAppTask(
            type: SurveyUserTask.SURVEY_TYPE,
            title: surveys.demographics.title,
            description: surveys.demographics.description,
            minutesToComplete: surveys.demographics.minutesToComplete,
            notification: true,
            rpTask: surveys.demographics.survey,
        ),
        phone);


    // TEST STUFF
    protocol.addTaskControl(
        RecurrentScheduledTrigger(type: RecurrentType.daily, time: const TimeOfDay(hour: 22, minute: 30, second: 0)),
        RPAppTask(
          type: SurveyUserTask.SURVEY_TYPE,
          title: surveys.dailyRecap.title,
          description: surveys.dailyRecap.description,
          minutesToComplete: surveys.dailyRecap.minutesToComplete,
          notification: true,
          rpTask: surveys.dailyRecap.survey,
          measures: [
            Measure(type: ContextSamplingPackage.MOBILITY),
          ]
        ),
        phone);

    // Add a task that keeps reappearing when done.
    var mobilityTask = AppTask(
        type: BackgroundSensingUserTask.ONE_TIME_SENSING_TYPE,
        title: "Mobility",
        description: "Collect mobility features",
        measures: [
          Measure(type: ContextSamplingPackage.MOBILITY),
        ]);

    protocol.addTaskControl(
        ImmediateTrigger(),
        mobilityTask,
        phone);

    protocol.addTaskControl(
        UserTaskTrigger(
            taskName: mobilityTask.name,
            triggerCondition: UserTaskState.done),
        mobilityTask,
        phone);


    return protocol;
  }

  @override
  Future<bool> saveStudyProtocol(String id, SmartphoneStudyProtocol protocol) {
    // TODO: implement saveStudyProtocol
    throw UnimplementedError();
  }
}