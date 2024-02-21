import 'package:flutter/material.dart';

import '../../models/metrics_models/screen_activity_metrics_model.dart';

class ScreenMetricsDisplayWidget extends StatelessWidget {
  final ScreenActivityMetricsModel model;

  const ScreenMetricsDisplayWidget({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Number of Uses:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '${model.numberOfUses}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        const Text(
          'Average Use Time:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          "${model.averageUseTime.toStringAsFixed(2)} minutes", // Mostra solo 2 cifre decimali
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        const Text(
          'Total Use Time:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '${model.totalUseTime.toStringAsFixed(2)} minutes',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
