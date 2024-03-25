import 'package:flutter/cupertino.dart';
import 'package:magicarp/src/bloc/metrics/screen_activity_metrics.dart';
import 'package:magicarp/src/bloc/sensing_bloc.dart';

class ScreenActivityMetricsModel extends ChangeNotifier{
  // Get the singleton instance of ScreenActivityMetrics
  static final ScreenActivityMetrics _screenActivityMetrics = bloc.screenActivityMetrics;

  // Singleton
  static final ScreenActivityMetricsModel _instance = ScreenActivityMetricsModel._internal();
  factory ScreenActivityMetricsModel() => _instance;
  ScreenActivityMetricsModel._internal() {
    _screenActivityMetrics.addListener(() {
      notifyListeners();
    });
  }

  /// The instance of the model
  static ScreenActivityMetricsModel get instance => _instance;

  /// The total number of uses of the phone by the user
  int get numberOfUses => _screenActivityMetrics.numberOfUses;

  /// The average use time in minutes
  double get averageUseTime => (_screenActivityMetrics.averageUseTime) / (1000 * 60);

  // The total use time in minutes
  double get totalUseTime => (_screenActivityMetrics.totalUseTime) / (1000 * 60);

  // Notifies listeners about changes in data
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}