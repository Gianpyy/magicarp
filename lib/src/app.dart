import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:magicarp/src/bloc/connectivity_bloc.dart';
import 'package:magicarp/src/ui/data_visualization_page.dart';
import 'package:magicarp/src/ui/probe_list.dart';
import 'package:magicarp/src/ui/study_deployment_page.dart';
import 'package:magicarp/src/ui/task_list_page.dart';
import 'bloc/sensing_bloc.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(FirstTaskHandler());
}

class FirstTaskHandler extends TaskHandler {
  SendPort? _sendPort;

  /// Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;

    // You can use the getData function to get the stored data.
    final customData =
    await FlutterForegroundTask.getData<String>(key: 'customData');
    log('customData: $customData');
  }

  /// Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // Send data to the main isolate.
    sendPort?.send(timestamp);
  }

  /// Called when the notification button on the Android platform is pressed.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {

  }

  /// Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    log('onNotificationButtonPressed >> $id');
  }

  /// Called when the notification itself on the Android platform is pressed.
  //
  /// "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  /// this function to be called.
  @override
  void onNotificationPressed() {
    // Note that the app will only route to "/resume-route" when it is exited so
    // it will usually be necessary to send a message through the send port to
    // signal it to restore state when the app is already started.
    FlutterForegroundTask.launchApp("/resume-route");
    _sendPort?.send('onNotificationPressed');
  }
}

class App extends StatelessWidget {
  const App({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoadingPage(),
        '/resume-route': (context) => const ResumePage(),
      },
    );
  }
}

/// A loading page shown while the app is loading and setting up the sensing layer.
class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});


  /// This method is used to set up the entire up, including:
  /// * initialize the bloc
  /// * authenticate the user
  /// * get the invitation
  /// * get the study
  /// * initialize sensing
  /// * start sensing
  Future<bool> init(BuildContext context) async {
    // Initialize the study
    await sensingBloc.sensing.initialize();

    // Initialize the connectivity bloc
    await connectivityBloc.initialize();

    // Save the bloc
    //await FlutterForegroundTask.saveData(key: 'bloc', value: bloc);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: init(context),
        builder: (context, snapshot) => (!snapshot.hasData)
            ? Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [CircularProgressIndicator()],
                  ),
                ),
            )
            : CarpMobileSensingApp(key: key),
    );
  }
}

/// A page that is shown when the foreground service is resumed after
class ResumePage extends StatefulWidget {
  const ResumePage({super.key});

  @override
  State<ResumePage> createState() => _ResumePageState();
}

class _ResumePageState extends State<ResumePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [CircularProgressIndicator()],
        ),
      ),
    );
  }

  @override
  void initState() {
    Navigator.of(context).pop();
    super.initState();
  }
}

/// The main view of the app, shown once loading is done.
class CarpMobileSensingApp extends StatefulWidget {
  const CarpMobileSensingApp({super.key});

  @override
  State<CarpMobileSensingApp> createState() => _CarpMobileSensingAppState();
}

class _CarpMobileSensingAppState extends State<CarpMobileSensingApp> {
  int _selectedIndex = 0;
  ReceivePort? _receivePort;

  final _pages = [
    const StudyDeploymentPage(),
    const ProbeList(),
    //const DeviceList(),
    const TaskList(),
    //const DataVisualizationPage(),
  ];

  Future<void> _requestPermissionForAndroid() async {
    if (!Platform.isAndroid) {
      return;
    }

    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      // This function requires `android.permission.SYSTEM_ALERT_WINDOW` permission.
      await FlutterForegroundTask.openSystemAlertWindowSettings();
    }

    // Android 12 or higher, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
    await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  // Initializes the FlutterForegroundTask
  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'foreground_service',
        channelName: 'Foreground Service Notification',
        channelDescription: 'This notification appears when the foreground service is running.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  Future<bool> _startForegroundTask() async {
    // You can save data using the saveData function.
    //await FlutterForegroundTask.saveData(key: 'customData', value: 'hello');

    // Register the receivePort before starting the service.
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);
    if (!isRegistered) {
      log('Failed to register receivePort!');
      return false;
    }

    if (await FlutterForegroundTask.isRunningService) {
      log("Restarting Foreground Service");
      return FlutterForegroundTask.restartService();
    } else {
      log("Starting Foreground Service");
      return FlutterForegroundTask.startService(
        notificationTitle: 'Foreground Service is running',
        notificationText: 'Tap to return to the app',
        notificationIcon: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
        callback: startCallback,
      );
    }
  }

  Future<bool> _stopForegroundTask() {
    log("Stopping Foreground Service");
    return FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) {
      if (data is int) {
        log('eventCount: $data');
      } else if (data is String) {
        if (data == 'onNotificationPressed') {
          Navigator.of(context).pushNamed('/resume-route');
        }
      } else if (data is DateTime) {
        log('timestamp: ${data.toString()}');
      }
    });

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissionForAndroid();
      _initForegroundTask();

      // You can get the previous ReceivePort without restarting the service.
      if (await FlutterForegroundTask.isRunningService) {
        final newReceivePort = FlutterForegroundTask.receivePort;
        _registerReceivePort(newReceivePort);
      }
    });
  }

  @override
  void dispose() {
    //bloc.stop();
    _closeReceivePort();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
        child: Scaffold(
          body: _pages[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.school), label: "Study"),
              BottomNavigationBarItem(icon: Icon(Icons.adb), label: "Probes"),
              //BottomNavigationBarItem(icon: Icon(Icons.watch), label: "Devices"),
              BottomNavigationBarItem(icon: Icon(Icons.spellcheck), label: "Tasks"),
              //BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: "Data"),
            ],
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            onTap: _onItemTapped,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _restart,
            tooltip: "Restart study & probes",
            child: sensingBloc.isRunning ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
          ),
        ),
    );
  }

  void _onItemTapped(int index) => setState(() {
    _selectedIndex = index;
  });

  void _restart() {
    setState(() {
      if (sensingBloc.isRunning) {
        log("Stop button pressed");
        sensingBloc.stop();
        _stopForegroundTask();
      } else {
        sensingBloc.start();
        log("Start button pressed");
        _startForegroundTask();
      }
    });
  }
}