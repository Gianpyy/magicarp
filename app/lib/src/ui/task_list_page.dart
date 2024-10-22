import 'package:flutter/material.dart';
import 'cards/task_card.dart';
import '../bloc/sensing_bloc.dart';
import 'package:carp_mobile_sensing/runtime.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  static const String routeName = '/tasklist';

  @override
  TaskListPageState createState() => TaskListPageState();
}

class TaskListPageState extends State<TaskListPage> {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    List<UserTask> tasks = sensingBloc.tasks.reversed.toList();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? Icons.more_horiz
                  : Icons.more_vert,
            ),
            tooltip: 'Settings',
            onPressed: _showSettings,
          ),
        ],
      ),
      body: StreamBuilder<UserTask>(
        stream: AppTaskController().userTaskEvents,
        builder: (context, AsyncSnapshot<UserTask> snapshot) {
          return Scrollbar(
            child: ListView.builder(
              itemCount: tasks.length,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (context, index) => TaskCard(userTask: tasks[index]),
            ),
          );
        },
      ),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings not implemented yet...')));
  }
}
