import 'package:flutter/material.dart';

import '../../models/probe_model.dart';

class ProbeCard extends StatelessWidget {
  final ProbeModel model;

  const ProbeCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                model.icon ?? const Icon(Icons.device_unknown),
                const SizedBox(width: 10),
                Text(
                  model.name ?? 'Unknown Probe',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(" "),
                model.stateIcon ?? const Icon(Icons.help_outline),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              model.description ?? 'No description available',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
