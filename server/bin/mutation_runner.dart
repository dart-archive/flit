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

  // DeviceManager dm = context[DeviceManager];
  // var devices = await dm.getDevices();

  // print(devices);

  // print ("Devices enum complete");

  print ("About to create Run");

  RunCommand runCmd = new RunCommand(
    '/Users/lukechurch/GitRepos/flutter',
    "/Users/lukechurch/GitRepos/flit/myapp/lib/main.dart");

  runCmd.verifyThenRunCommand();
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

  while (true) {
    print ("attempting restart");
    await hotRunner.restart(fullRestart: true);
    print ("Restart complete");
    await new Future.delayed(new Duration(seconds: 5));
  }

  // print('isolate = ' + runCmd.vmService.vm.mainView.uiIsolate.toString());
  //print(runCmd.vmService.vm.mainView.uiIsolate.flutterDebugReturnElementTree());


// InstallCommand installCommand = new InstallCommand();
// installCommand.run();
  //
  // RunCommand runCommand = new RunCommand();
  // runCommand.argResults = new
  // runCommand.argResults['hot'] = true;
  // runCommand.run();

}
