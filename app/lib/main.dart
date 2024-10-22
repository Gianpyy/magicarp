import 'package:carp_mobile_sensing/carp_mobile_sensing.dart';
import 'package:magicarp/src/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:magicarp/src/bloc/sensing_bloc.dart';
import 'package:flutter_foreground_service/flutter_foreground_service.dart';

void main() async{
  // Makes sure to have an instance of the WidgetsBinding, which is required
  // to use platform channels to call native code
  // see also >> https://stackoverflow.com/questions/63873338/what-does-widgetsflutterbinding-ensureinitialized-do/63873689
  WidgetsFlutterBinding.ensureInitialized();

  // Make sure to initialize CAMS incl. json serialization
  CarpMobileSensing.ensureInitialized();

  // Initialize the bloc, setting the deployment mode:
  //  * local
  //  * carpStaging
  //  * carpProduction
  await sensingBloc.initialize(
    deploymentMode: DeploymentMode.local,
    useCachedStudyDeployment: false,
    resumeSensingOnStartup: false,
  );

  runApp(const App());
}
