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

  Completer<DebugConnectionInfo> debugInfoCompleter =
      new Completer<DebugConnectionInfo>();
  hotRunner.run(
    connectionInfoCompleter: debugInfoCompleter,
    route: route,
    shouldBuild: true,
  );
  DebugConnectionInfo debugInfo = await debugInfoCompleter.future;

  await hotRunner.connectToServiceProtocol(debugInfo.port);

  new io.File(diagPath).watch().listen((io.FileSystemEvent event) async {
    print(">>> ${event.type}, ${event.path}");
    print("attempting restart");
    await hotRunner.restart(fullRestart: true);
    print("Restart complete");
    await new Future.delayed(new Duration(seconds: 5));
  });
}
