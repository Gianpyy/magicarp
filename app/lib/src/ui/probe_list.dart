import 'package:flutter/material.dart';

import '../models/probe_model.dart';
import 'cards/probe_card.dart';

class ProbeListPage extends StatelessWidget {
  final List<ProbeModel> probes;

  const ProbeListPage({super.key, required this.probes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Active Sensors"),
      ),
      body: ListView.builder(
        itemCount: probes.length,
        itemBuilder: (context, index) {
          return ProbeCard(model: probes[index]);
        },
      ),
    );
  }
}
