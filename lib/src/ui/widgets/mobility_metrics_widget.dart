import 'package:flutter/cupertino.dart';
import 'package:magicarp/src/models/metrics_models/mobility_metrics_model.dart';
import 'package:provider/provider.dart';

class MobilityMetricsDisplayWidget extends StatelessWidget {
  const MobilityMetricsDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MobilityMetricsModel>(
      builder: (context, model, _) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Last time:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${model.lastTime}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Distance traveled:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${model.distanceTraveled}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Number of places:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${model.numberOfPlaces}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Location variance:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${model.locationVariance?.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Entropy:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${model.entropy?.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Normalized entropy:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${model.normalizedEntropy?.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              "Home stay:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "${model.homeStay?.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
          ],
        );
      }
    );
  }
}