import 'dart:io' as io;
import 'dart:async';

import 'package:flutter_tools/src/base/common.dart';
import 'package:flutter_tools/src/build_info.dart';
import 'package:flutter_tools/src/cache.dart';
import 'package:flutter_tools/src/device.dart';
import 'package:flutter_tools/src/doctor.dart';
import 'package:flutter_tools/src/base/context.dart';
import 'package:flutter_tools/src/base/logger.dart';
import 'package:flutter_tools/src/globals.dart';
import 'package:flutter_tools/src/hot.dart';

import 'package:flutter_tools/src/vmservice.dart';
import 'package:path/path.dart' as path;

import 'package:flutter_tools/src/resident_runner.dart';

main(List<String> args) async {
  String flutterRoot = '../../flutter';
  String target = "lib/myapp.dart";
  String route = "/";
  String diagPath = "lib/diagnostics.dart";

  // Initialize globals.
  Cache.flutterRoot = path.normalize(path.absolute(flutterRoot));
  context[Logger] = new StdoutLogger();
  context[DeviceManager] = new DeviceManager();
//  context[AndroidSdk] = AndroidSdk.locateAndroidSdk();
  Doctor.initGlobal();

  List<Device> allDevices = await deviceManager.getAllConnectedDevices();

  DebuggingOptions debugOptions = new DebuggingOptions.enabled(
    BuildMode.debug,
    startPaused: false,
    observatoryPort: kDefaultObservatoryPort,
  );
  HotRunner hotRunner = new HotRunner(
    allDevices.first,
    target: target,
    debuggingOptions: debugOptions,
  );

  // Launch the application
  Completer<DebugConnectionInfo> debugInfoCompleter =
      new Completer<DebugConnectionInfo>();
  Future<int> run = hotRunner.run(
    connectionInfoCompleter: debugInfoCompleter,
    route: route,
    shouldBuild: true,
  );
  bool running = true;

  // Wait for application to start and VM service to connect
  DebugConnectionInfo debugInfo = await debugInfoCompleter.future;
  await hotRunner.connectToServiceProtocol(debugInfo.port);
  VMService vmService = hotRunner.vmService;

  var m = hotRunner.currentView.uiIsolate.flutterDebugReturnElementTree();
  print(await m);

  // Update the running application whenever the diagFile changes
  io.File diagFile = new io.File(diagPath);
  StreamSubscription<io.FileSystemEvent> subscription;
  void watchDiagFile() {
    subscription = diagFile.watch().listen((io.FileSystemEvent event) async {
      print("attempting restart");
      await hotRunner.restart(fullRestart: true);
      print("restart complete");

      // If diagFile was deleted when wait for it to be recreated
      // before watching the file again
      if (event.type == io.FileSystemEvent.DELETE) {
        subscription?.cancel();
        subscription = null;
        while (running && !await diagFile.exists()) {
          await new Future.delayed(new Duration(milliseconds: 10));
        }

        // If application has not exited, then watch the diagFile again
        if (running)
          watchDiagFile();
      }
    });
  }
  watchDiagFile();

  // Cleanup when the application exits
  run.then((int exitCode) {
    print('application exit: $exitCode');
    subscription?.cancel();
    subscription = null;
    running = false;
  });
}
