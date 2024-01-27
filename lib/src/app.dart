import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magicarp/src/sensing/sensing.dart';
import 'package:magicarp/src/ui/study_deployment_page.dart';

import 'bloc/sensing_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const LoadingPage(),
    );
  }
}

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
    await Sensing().initialize();

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

class CarpMobileSensingApp extends StatefulWidget {
  const CarpMobileSensingApp({super.key});

  @override
  State<CarpMobileSensingApp> createState() => _CarpMobileSensingAppState();
}

class _CarpMobileSensingAppState extends State<CarpMobileSensingApp> {
  int _selectedIndex = 0;

  final _pages = [
    const StudyDeploymentPage(),
    const Placeholder(),
    const Placeholder(),
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
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: restart,
        tooltip: "Restart study & probes",
        child: bloc.isRunning ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      ),
    );
  }

  void _onItemTapped(int value) {
    setState(() {
      _selectedIndex = value;
    });
  }

  void restart() {
    setState(() {
      if(bloc.isRunning) {
        bloc.stop();
      }
      else {
        bloc.resume();
      }
    });
  }
}