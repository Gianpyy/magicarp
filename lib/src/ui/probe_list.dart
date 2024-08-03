import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:flutter/material.dart';

import '../bloc/sensing_bloc.dart';
import '../models/probe_model.dart';

class ProbeList extends StatefulWidget {
  const ProbeList({super.key});

  @override
  State<ProbeList> createState() => _ProbeListState();
}

class _ProbeListState extends State<ProbeList> {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Iterable<Widget> probes = ListTile.divideTiles(
        tiles: bloc.runningProbes.map<Widget>((probe) => _buildProbeListTile(probe))
    );

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Probes'),
        //TODO - move actions/settings icon to the app level.
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? Icons.more_horiz
                  : Icons.more_vert,
            ),
            tooltip: 'Settings',
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: probes.toList(),
        ),
      ),
    );
  }

  Widget _buildProbeListTile(ProbeModel probe) {
    return ListTile(
      isThreeLine: true,
      leading: probe.icon,
      title: Text(probe.name ?? "Unknown"),
      subtitle: Text(probe.description ?? "..."),
      trailing: probe.stateIcon,
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings not implemented yet...')));
  }
}