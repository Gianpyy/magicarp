import 'dart:async';

import 'package:carp_context_package/carp_context_package.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:carp_serializable/carp_serializable.dart';
import 'package:flutter/material.dart';
import 'package:magicarp/sensing.dart';
import 'package:mobility_features/mobility_features.dart';


/// Widget that visualizes the sensed data
class ConsolePage extends StatefulWidget {
  final String title;
  const ConsolePage({super.key, required this.title});

  @override
  Console createState() => Console();
}


/// A simple UI with a console that shows the sensed data in a json format
class Console extends State<ConsolePage> {
  String _log = '';
  Sensing? sensing;

  // Location Streaming
  // late Stream<Location> locationStream;
  // late StreamSubscription<Location> locationSubscription;
  //
  // // Mobility Features stream
  // late StreamSubscription<MobilityContext> mobilitySubscription;
  // late MobilityContext _mobilityContext;

  @override
  void initState() {
    sensing = Sensing();
    Settings().init().then((_) {
      // Configuration of Mobility Features plugin
      // MobilityFeatures().stopDuration = const Duration(seconds: 20);
      // MobilityFeatures().placeRadius = 50;
      // MobilityFeatures().stopRadius = 5.0;

      // Initialization of sensing
      sensing?.init().then((_) {
        log('Setting up study: ${sensing?.study}');
        log('Deployment status: ${sensing?.status}');
        Future.delayed(const Duration(seconds: 1), () {
          sensing?.resume();
          log('\nSensing resumed ...');
        });
      });
    });

    super.initState();
  }

  /// Set up streams:
  /// * Location streaming to MobilityContext
  /// * Subscribe to MobilityContext updates
  // void streamInit() async {
  //   locationStream = LocationManager().onLocationChanged;
  //
  //   // Subscribe to location stream - in case this is needed in the app
  //   locationSubscription = locationStream.listen(onLocationUpdate);
  //
  //   // Map from [LocationDto] to [LocationSample]
  //   Stream<LocationSample> locationSampleStream = locationStream.map(
  //           (location) => LocationSample(
  //           GeoLocation(location.latitude, location.longitude),
  //           DateTime.now()));
  //
  //   // Provide the [MobilityFeatures] instance with the LocationSample stream
  //   MobilityFeatures().startListening(locationSampleStream);
  //
  //   // Start listening to incoming MobilityContext objects
  //   mobilitySubscription = MobilityFeatures().contextStream.listen(onMobilityContext);
  // }

  /// Called whenever location changes.
  // void onLocationUpdate(Location dto) {
  //   log(toJsonString(dto));
  // }
  //
  // /// Called whenever mobility context changes.
  // void onMobilityContext(MobilityContext context) {
  //   log('Context received: ${context.toJson()}');
  //   setState(() {
  //     _mobilityContext = context;
  //   });
  // }

  @override
  void dispose() {
    log("\nDisposed of current sensing.");
    // mobilitySubscription.cancel();
    // locationSubscription.cancel();
    sensing!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: sensing?.client?.measurements,
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) _log += "${toJsonString(snapshot.data)}\n";
              return Text(_log);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: restart,
        tooltip: "Restart study & probes",
        child: sensing!.isRunning ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      ),
    );
  }

  void log(String msg) {
    setState(() {
      _log += '$msg\n';
    });
  }

  void clearLog() {
    setState(() {
      _log += '';
    });
  }

  void restart() {
    setState(() {
      if (sensing!.isRunning) {
        sensing!.stop();
        log('\nSensing stopped ...');
      } else {
        sensing!.resume();
        log('\nSensing resumed ...');
      }
    });
  }
}