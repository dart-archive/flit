// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter_tools/src/base/common.dart';
import 'package:flutter_tools/src/base/utils.dart';
import 'package:flutter_tools/src/build_info.dart';
import 'package:flutter_tools/src/cache.dart';
import 'package:flutter_tools/src/device.dart';
import 'package:flutter_tools/src/globals.dart';
import 'package:flutter_tools/src/hot.dart';
import 'package:flutter_tools/src/resident_runner.dart';
// import 'package:flutter_tools/src/run.dart';
import 'run.dart';
import 'package:flutter_tools/src/runner/flutter_command.dart';

import 'package:path/path.dart' as path;

int observatoryPort;

abstract class RunCommandBase extends FlutterCommand {
  RunCommandBase() {
    addBuildModeFlags(defaultToRelease: false);
    usesTargetOption();
  }

  bool get traceStartup => false; //argResults['trace-startup'];
  // String get route => argResults['route'];
}

class RunCommand extends RunCommandBase {
  @override
  final String name = 'run';

  @override
  final String description = 'Run your Flutter app on an attached device.';

  bool fullRestart_arg;
  bool startPaused_arg;
  int debugPort_arg;
  bool build_arg;
  bool pub_arg;
  bool hot_arg;
  String pidFile_arg;

  var buildMode = BuildMode.debug;


  // TODO: Make these options
  String get targetFile => "/Users/lukechurch/GitRepos/flit/myapp/lib/main.dart";
  String route  = "/";

  RunCommand() {
    Cache.flutterRoot = path.normalize(path.absolute('/Users/lukechurch/GitRepos/flutter'));
    fullRestart_arg = true;
    startPaused_arg = false;
    debugPort_arg = kDefaultObservatoryPort;
    build_arg = true;
    pub_arg = true;
    hot_arg = false;
    pidFile_arg = null;
  }

  @override
  bool get requiresDevice => true;

  @override
  Future<int> runInProject() async {
    int debugPort;
    if (deviceForCommand.isLocalEmulator && !isEmulatorBuildMode(buildMode)) {
      printError('${toTitleCase(getModeName(buildMode))} mode is not supported for emulators.');
      return 1;
    }

    DebuggingOptions options;


    if (buildMode == BuildMode.release) {
      options = new DebuggingOptions.disabled(buildMode);
    } else {
      options = new DebuggingOptions.enabled(
        buildMode,
        startPaused: startPaused_arg,
        observatoryPort: debugPort
      );
    }

    printTrace("about to release lock on cache");

    Cache.releaseLockEarly();

    // Do some early error checks for hot mode.
    bool hotMode = hot_arg;

    if (hotMode) {
      if (buildMode != BuildMode.debug) {
        printError('Hot mode only works with debug builds.');
        return 1;
      }
      if (!deviceForCommand.supportsHotMode) {
        printError('Hot mode is not supported by this device.');
        return 1;
      }
    }

    String pidFile = pidFile_arg;
    if (pidFile != null) {
      // Write our pid to the file.
      new File(pidFile).writeAsStringSync(pid.toString());
    }
    ResidentRunner runner;

    if (hot_arg) {
      runner = new HotRunner(
        deviceForCommand,
        target: targetFile,
        debuggingOptions: options
      );
    } else {
      runner = new RunAndStayResident(
        deviceForCommand,
        target: targetFile,
        debuggingOptions: options,
        traceStartup: traceStartup,
        benchmark: null, //argResults['benchmark'],
        applicationBinary: null //argResults['use-application-binary']
      );
    }

    print ("Calling runner with route: $route");
    print ("Runner type: ${runner.runtimeType}");

    return runner.run(route: route, shouldBuild: build_arg);
  }
}
