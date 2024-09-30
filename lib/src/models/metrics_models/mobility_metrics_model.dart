import 'package:flutter/cupertino.dart';
import '../../bloc/metrics/mobility_metrics.dart';
import '../../bloc/sensing_bloc.dart';

class MobilityMetricsModel extends ChangeNotifier{
  // Get the singleton instance of ScreenActivityMetrics
  static final MobilityMetrics _mobilityMetrics = sensingBloc.mobilityMetrics;

  // Singleton
  static final MobilityMetricsModel _instance = MobilityMetricsModel._internal();
  factory MobilityMetricsModel() => _instance;
  MobilityMetricsModel._internal() {
    _mobilityMetrics.addListener(() {
      notifyListeners();
    });
  }

  /// The instance of the model
  static MobilityMetricsModel get instance => _instance;

  /// The distance traveled on the current day, in meters
  double? get distanceTraveled => _mobilityMetrics.distanceTraveled;

  /// The value of home stay on the current day
  /// normalized in a value between 0 and 1
  double? get homeStay => _mobilityMetrics.homeStay;

  /// The location entropy value on the current day
  /// normalized in a value between 0 and 1
  double? get normalizedEntropy => _mobilityMetrics.normalizedEntropy;

  /// The location entropy value on the current day
  double? get entropy => _mobilityMetrics.entropy;

  /// The location variance on the current day
  double? get locationVariance => _mobilityMetrics.locationVariance;

  /// The number of places visited on the current day
  int? get numberOfPlaces => _mobilityMetrics.numberOfPlaces;

  /// The date and time of the last time this measure was collected
  DateTime? get lastTime => _mobilityMetrics.lastTime;

  // Notifies listeners about changes in data
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}