import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:flutter/material.dart';

import '../ui/colors.dart';


class DeviceModel {
  DeviceManager deviceManager;
  String? get type => deviceManager.type;
  DeviceStatus get status => deviceManager.status;
  Stream<DeviceStatus> get deviceEvents => deviceManager.statusEvents;

  /// The device id.
  String get id => deviceManager.id;

  /// A printer-friendly name for this device.
  String? get name => deviceTypeName[type!];

  /// A printer-friendly description of this device.
  String get description => '${deviceTypeDescription[type!]} - $statusString'
      '${(deviceManager is HardwareDeviceManager && batteryLevel != null) ? '\n$batteryLevel% battery remaining.' : ''}';

  String get statusString => status.toString().split('.').last;

  /// The battery level of this device, if known.
  int? get batteryLevel => deviceManager is HardwareDeviceManager
      ? (deviceManager as HardwareDeviceManager).batteryLevel
      : null;

  /// The icon for this type of device.
  Icon? get icon => deviceTypeIcon[type!];

  /// The icon for the runtime state of this device.
  Icon? get stateIcon => deviceStateIcon[status];

  DeviceModel(this.deviceManager) : super();

  static Map<String, String> get deviceTypeName => {
    Smartphone.DEVICE_TYPE: 'Phone',
    // ESenseDevice.DEVICE_TYPE: 'eSense',
    // PolarDevice.DEVICE_TYPE: 'Polar',
    // LocationService.DEVICE_TYPE: 'Location',
    // AirQualityService.DEVICE_TYPE: 'Air Quality',
    // WeatherService.DEVICE_TYPE: 'Weather',
  };

  static Map<String, String> get deviceTypeDescription => {
    Smartphone.DEVICE_TYPE: 'This phone',
    // ESenseDevice.DEVICE_TYPE: 'eSense Ear Plug',
    // PolarDevice.DEVICE_TYPE: 'Polar HR Monitor',
    // LocationService.DEVICE_TYPE: 'Location Service',
    // AirQualityService.DEVICE_TYPE: 'World Air Quality Service',
    // WeatherService.DEVICE_TYPE: 'Open Weather Service',
  };

  static Map<String, Icon> get deviceTypeIcon => {
    Smartphone.DEVICE_TYPE: const Icon(Icons.phone_android, size: 50, color: CACHET.GREY_4),
    // ESenseDevice.DEVICE_TYPE:
    // Icon(Icons.headset, size: 50, color: CACHET.CACHET_BLUE),
    // PolarDevice.DEVICE_TYPE:
    // Icon(Icons.monitor_heart, size: 50, color: CACHET.RED),
    // LocationService.DEVICE_TYPE:
    // Icon(Icons.location_on, size: 50, color: CACHET.GREEN),
    // AirQualityService.DEVICE_TYPE:
    // Icon(Icons.air, size: 50, color: CACHET.LIGHT_GREEN),
    // WeatherService.DEVICE_TYPE:
    // Icon(Icons.cloud, size: 50, color: CACHET.DARK_BLUE),
  };

  static Map<DeviceStatus, Icon> get deviceStateIcon => {
    DeviceStatus.unknown: const Icon(Icons.error_outline, color: CACHET.RED),
    DeviceStatus.error: const Icon(Icons.error_outline, color: CACHET.RED),
    DeviceStatus.disconnected: const Icon(Icons.close, color: CACHET.YELLOW),
    DeviceStatus.connected: const Icon(Icons.check, color: CACHET.GREEN),
    DeviceStatus.paired: const Icon(Icons.bluetooth_connected, color: CACHET.DARK_BLUE),
  };
}