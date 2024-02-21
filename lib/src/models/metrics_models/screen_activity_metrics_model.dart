import 'package:magicarp/src/bloc/metrics/screen_activity_metrics.dart';
import 'package:magicarp/src/bloc/sensing_bloc.dart';

class ScreenActivityMetricsModel {
  final ScreenActivityMetrics _screenActivityMetrics = bloc.screenActivityMetrics;

  /// The total number of uses of the phone by the user
  int get numberOfUses => _screenActivityMetrics.numberOfUses;

  /// The average use time in minutes
  double get averageUseTime => (_screenActivityMetrics.averageUseTime) / (1000 * 60);

  // The total use time in minutes
  double get totalUseTime => (_screenActivityMetrics.totalUseTime) / (1000 * 60);
}