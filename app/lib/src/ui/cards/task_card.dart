import 'package:carp_survey_package/survey.dart';
import 'package:flutter/material.dart';
import 'package:carp_mobile_sensing/runtime.dart';
import '../colors.dart';

class TaskCard extends StatelessWidget {
  final UserTask userTask;

  const TaskCard({super.key, required this.userTask});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: StreamBuilder<UserTaskState>(
          stream: userTask.stateEvents,
          initialData: UserTaskState.initialized,
          builder: (context, AsyncSnapshot<UserTaskState> snapshot) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: taskTypeIcon[userTask.type],
                title: Text(userTask.title),
                subtitle: Text(userTask.description),
                trailing: taskStateIcon[userTask.state],
              ),
              (userTask.availableForUser)
                  ? ButtonBar(
                children: <Widget>[
                  TextButton(
                    child: const Text('PRESS HERE TO FINISH TASK'),
                    onPressed: () {
                      userTask.onStart();
                      if (userTask.hasWidget) {
                        Navigator.push(
                          context,
                          MaterialPageRoute<Widget>(
                            builder: (context) => userTask.widget!,
                          ),
                        );
                      }
                    },
                  ),
                ],
              )
                  : const Text(""),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, Icon> get taskTypeIcon => {
    SurveyUserTask.SURVEY_TYPE: const Icon(
      Icons.description,
      color: CACHET.ORANGE,
      size: 40,
    ),
    SurveyUserTask.COGNITIVE_ASSESSMENT_TYPE: const Icon(
      Icons.face,
      color: CACHET.YELLOW,
      size: 40,
    ),
    BackgroundSensingUserTask.SENSING_TYPE: const Icon(
      Icons.settings_input_antenna,
      color: CACHET.CACHET_BLUE,
      size: 40,
    ),
    BackgroundSensingUserTask.ONE_TIME_SENSING_TYPE: const Icon(
      Icons.settings_input_component,
      color: CACHET.CACHET_BLUE,
      size: 40,
    ),
  };

  Map<UserTaskState, Icon> get taskStateIcon => {
    UserTaskState.initialized: const Icon(Icons.stream, color: CACHET.YELLOW),
    UserTaskState.enqueued: const Icon(Icons.notifications, color: CACHET.YELLOW),
    UserTaskState.dequeued: const Icon(Icons.not_interested_outlined, color: CACHET.RED),
    UserTaskState.started: const Icon(Icons.radio_button_checked, color: CACHET.GREEN),
    UserTaskState.canceled: const Icon(Icons.radio_button_off, color: CACHET.RED),
    UserTaskState.done: const Icon(Icons.check, color: CACHET.GREEN),
  };
}
