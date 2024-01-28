import 'package:flutter/cupertino.dart';
import 'package:magicarp/src/app.dart';
import 'package:magicarp/src/bloc/sensing_bloc.dart';

void main() async{
  // makes sure to have an instance of the WidgetsBinding, which is required
  // to use platform channels to call native code
  // see also >> https://stackoverflow.com/questions/63873338/what-does-widgetsflutterbinding-ensureinitialized-do/63873689
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the bloc, setting the deployment mode:
  //  * local
  //  * carpStaging
  //  * carpProduction
  await bloc.initialize(
    deploymentMode: DeploymentMode.local,
    useCachedStudyDeployment: false,
    resumeSensingOnStartup: false,
  );

  runApp(const App());
}
