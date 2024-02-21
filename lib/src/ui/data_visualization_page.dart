import 'package:flutter/material.dart';
import 'package:magicarp/src/models/metrics_models/screen_activity_metrics_model.dart';
import 'package:magicarp/src/ui/widgets/screen_activity_metrics_widget.dart';

class DataVisualizationPage extends StatefulWidget {
  const DataVisualizationPage({super.key});

  @override
  State<DataVisualizationPage> createState() => _DataVisualizationPageState();
}

class _DataVisualizationPageState extends State<DataVisualizationPage> {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen Activity Metrics"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ScreenMetricsDisplayWidget(model: ScreenActivityMetricsModel()),
        ),
      ),
    );
  }
}