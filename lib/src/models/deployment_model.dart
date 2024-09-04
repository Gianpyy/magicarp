import 'package:carp_core/carp_core.dart';
import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:flutter/material.dart';
import '../bloc/sensing_bloc.dart';
import '../sensing/sensing.dart';

/// A view model for the [StudyDeploymentPage] view.
class StudyDeploymentModel {
  SmartphoneDeployment deployment;

  String get title => deployment.studyDescription?.title ?? '';
  String get description =>
      deployment.studyDescription?.description ?? 'No description available.';
  Image get image => Image.asset("assets/img/study.png");
  String get studyDeploymentId => deployment.studyDeploymentId;
  String get userID => deployment.userId ?? '';
  String get dataEndpoint => deployment.dataEndPoint.toString();

  /// Events on the state of the study executor
  Stream<ExecutorState> get studyExecutorStateEvents =>
      sensingBloc.sensing.controller!.executor.stateEvents;

  /// Current state of the study executor (e.g., resumed, paused, ...)
  ExecutorState get studyState => sensingBloc.sensing.controller!.executor.state;

  /// Get all sensing events (i.e. all [Measurement] objects being collected).
  Stream<Measurement> get measurements =>
      sensingBloc.sensing.controller?.measurements ?? const Stream.empty();

  /// The total sampling size so far since this study was started.
  int get samplingSize => sensingBloc.sensing.controller!.samplingSize;

  StudyDeploymentModel(this.deployment) : super();
}