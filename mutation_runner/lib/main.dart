import 'dart:io' as io;
import 'dart:async';
import 'package:flutter_tools/src/android/android_sdk.dart';
import 'package:flutter_tools/src/device.dart';
import 'package:flutter_tools/src/doctor.dart';
import 'package:flutter_tools/src/base/context.dart';
import 'package:flutter_tools/src/base/logger.dart';
import 'package:flutter_tools/src/hot.dart';


// import 'package:flutter_tools/src/commands/run.dart';
// import 'package:flutter_tools/src/commands/install.dart';

import '../lib/run_command_new.dart';


main(List<String> args) async {

  // Initialize globals.
  context[Logger] = new StdoutLogger();
  context[DeviceManager] = new DeviceManager();
  Doctor.initGlobal();
  context[AndroidSdk] = AndroidSdk.locateAndroidSdk();

  String flutterPath = '~/GitRepos/flutter';
  String appMain = "../myapp/lib/main.dart";
  String diagPath = "../myapp/lib/diagnostics.dart";

  print ("About to create Run");

  RunCommand runCmd = new RunCommand(flutterPath, appMain);

  print('created RunCommand');
  runCmd.verifyThenRunCommand();

  print('verified RunCommand');

  HotRunner hotRunner;

  for (int i = 0; i < 20; i++) {
    await new Future.delayed(new Duration(seconds: 1));
    print ('Waiting');
    print('ElementTree');
    print('VM service = ' + runCmd.vmService.toString());
    hotRunner = runCmd.hotRunner;

    print('Hot runner = ${hotRunner.toString()}');
    print('VM service = ${hotRunner.vmService}');
  }


  print ("===========================================");
  print ("TODO: Something more sensible than this");
  print ("done waiting app should have started by now");
  print ("===========================================");

  new io.File(diagPath)
    .watch().listen((_) async {
      print ("attempting restart");
      await hotRunner.restart(fullRestart: true);
      print ("Restart complete");
      await new Future.delayed(new Duration(seconds: 5));
    });
}
