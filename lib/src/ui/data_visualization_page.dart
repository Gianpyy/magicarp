import 'package:flutter/material.dart';
import 'package:magicarp/src/models/metrics_models/mobility_metrics_model.dart';
import 'package:magicarp/src/models/metrics_models/screen_activity_metrics_model.dart';
import 'package:magicarp/src/ui/widgets/mobility_metrics_widget.dart';
import 'package:magicarp/src/ui/widgets/screen_activity_metrics_widget.dart';
import 'package:provider/provider.dart';

class DataVisualizationPage extends StatelessWidget {
  const DataVisualizationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenActivityModel = ScreenActivityMetricsModel.instance;
    final mobilityModel = MobilityMetricsModel.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Data visualization"),
      ),
      body: SingleChildScrollView (
        child: Center(
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Screen Activity Metrics",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ChangeNotifierProvider.value(
                    value: screenActivityModel,
                    child: const ScreenMetricsDisplayWidget(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Mobility Metrics",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ChangeNotifierProvider.value(
                    value: mobilityModel,
                    child: const MobilityMetricsDisplayWidget(),
                  ),
                ],
              )
          ),
        ),
      )
    );
  }
}