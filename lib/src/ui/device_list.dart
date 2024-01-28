import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:flutter/material.dart';
import '../bloc/sensing_bloc.dart';
import '../models/device_model.dart';

class DeviceList extends StatefulWidget {
  const DeviceList({super.key});

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    List<DeviceModel> devices = bloc.availableDevices.toList();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text("Devices"),
      ),
      body: StreamBuilder<UserTask>(
        stream: AppTaskController().userTaskEvents,
        builder: (context, AsyncSnapshot<UserTask> snapshot) {
          return Scrollbar(
              child: ListView.builder(
                itemCount: devices.length,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                itemBuilder: (context, index) => _buildTaskCard(context, devices[index]),
              ),
          );
        },
      ),
    );
  }

 Widget _buildTaskCard(BuildContext context, DeviceModel device) {
    return Center(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: StreamBuilder<DeviceStatus>(
          stream: device.deviceEvents,
          initialData: DeviceStatus.unknown,
          builder: (context, AsyncSnapshot<DeviceStatus> snapshot) => Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: device.icon,
                title: Text(device.id),
                subtitle: Text(device.description),
                trailing: device.stateIcon,
              ),
              const Divider(),
              TextButton(
                child: const Text("How to use this device?"),
                onPressed: () => print("Use the $device"),
              ),
              (device.status != DeviceStatus.connected)
              ? Column(
                children: [
                  const Divider(),
                  TextButton(
                    child: const Text("Connect to this device"),
                    onPressed: () => bloc.connectToDevice(device),
                  ),
                ],
              )
              : const Text(""),
            ],
          ),
        ),
      ),
    );
  }
}