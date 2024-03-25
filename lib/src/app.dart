import 'package:flutter/material.dart';
import 'package:magicarp/src/sensing/sensing.dart';
import 'package:magicarp/src/ui/data_visualization_page.dart';
import 'package:magicarp/src/ui/device_list.dart';
import 'package:magicarp/src/ui/probe_list.dart';
import 'package:magicarp/src/ui/study_deployment_page.dart';
import 'bloc/sensing_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const LoadingPage(),
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
    await bloc.sensing.initialize();

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

/// The main view of the app, shown once loading is done.
class CarpMobileSensingApp extends StatefulWidget {
  const CarpMobileSensingApp({super.key});

  @override
  State<CarpMobileSensingApp> createState() => _CarpMobileSensingAppState();
}

class _CarpMobileSensingAppState extends State<CarpMobileSensingApp> {
  int _selectedIndex = 0;

  final _pages = [
    const StudyDeploymentPage(),
    const ProbeList(),
    const DeviceList(),
    const DataVisualizationPage(),
  ];


  @override
  void dispose() {
    bloc.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Study"),
          BottomNavigationBarItem(icon: Icon(Icons.adb), label: "Probes"),
          BottomNavigationBarItem(icon: Icon(Icons.watch), label: "Devices"),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: "Data"),
        ],
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _restart,
        tooltip: "Restart study & probes",
        child: bloc.isRunning ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      ),
    );
  }

  void _onItemTapped(int index) => setState(() {
    _selectedIndex = index;
  });

  void _restart() =>
      setState(() => (bloc.isRunning) ? bloc.stop() : bloc.start());
}