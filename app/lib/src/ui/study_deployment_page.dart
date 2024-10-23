import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:flutter/material.dart';
import 'package:magicarp/src/models/deployment_model.dart';

import '../bloc/sensing_bloc.dart';
import 'colors.dart';

class StudyDeploymentPage extends StatelessWidget {
  final StudyDeploymentModel model;

  const StudyDeploymentPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  model.image,
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, 0.5),
                        end: Alignment(0.0, 0.0),
                        colors: <Color>[
                          Color(0x60000000),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Study Overview",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        model.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow("Study Deployment ID", model.studyDeploymentId),
                      _buildDetailRow("User ID", model.userID),
                      _buildDetailRow("Data Endpoint", model.dataEndpoint),
                      const SizedBox(height: 20),
                      Text(
                        "Sampling Information",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow("Sampling Size", model.samplingSize.toString()),
                      _buildDetailRow("Study State", model.studyState.name),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Wrap(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 8.0,
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
