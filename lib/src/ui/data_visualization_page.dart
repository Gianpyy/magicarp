import 'package:flutter/material.dart';
import 'package:magicarp/src/models/metrics_models/screen_activity_metrics_model.dart';
import 'package:magicarp/src/ui/widgets/screen_activity_metrics_widget.dart';
import 'package:provider/provider.dart';

class DataVisualizationPage extends StatelessWidget {
  const DataVisualizationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = ScreenActivityMetricsModel.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen Activity Metrics"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ChangeNotifierProvider.value(
            value: model,
            child: const ScreenMetricsDisplayWidget(),
          ),
        ),
      ),
    );
  }
}