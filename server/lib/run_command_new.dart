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
import 'package:flutter_tools/src/run.dart';
import 'package:flutter_tools/src/runner/flutter_command.dart';
import 'package:flutter_tools/src/vmservice.dart';

import 'package:path/path.dart' as path;


String global_flutterRoot;
String global_targetFile;

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

  final argsMap = const {
    'start-paused' : false,
    'hot' : true,
    'debug-port' : kDefaultObservatoryPort,
    'pid-file' : null,
    'benchmark' : null,
    'use-application-binary' : null,
    'build' : true,
    'trace-startup' : false,
    'route' : '/',
  };

  // bool fullRestart_arg = true;
  // bool startPaused_arg = false;
  // int debugPort_arg = kDefaultObservatoryPort;
  // bool build_arg = true;
  // bool pub_arg = true;
  // bool hot_arg = true;
  // String pidFile_arg = null;
  // String appBinary_arg = null;
  // bool benchmark_arg = arg;

  var buildMode = BuildMode.debug;
  HotRunner hotRunner;

  VMService vmService;

  String targetFile;
  Device device;


  String route  = "/";

  RunCommand(String flutterPath, this.targetFile) {
   Cache.flutterRoot = path.normalize(path.absolute(flutterPath));
  }


  @override
  Future<int> verifyThenRunCommand() async {
    if (!commandValidator())
      return 1;
    device = await findTargetDevice();
    if (device == null)
      return 1;
    return super.verifyThenRunCommand();
  }


    @override
    Future<int> runCommand() async {
      getBuildMode() => BuildMode.debug;

      int debugPort;

      if (argsMap['debug-port'] != null) {
        try {
          debugPort = argsMap;
        } catch (error) {
          printError('Invalid port for `--debug-port`: $error');
          return 1;
        }
      }

      if (device.isLocalEmulator && !isEmulatorBuildMode(getBuildMode())) {
        printError('${toTitleCase(getModeName(getBuildMode()))} mode is not supported for emulators.');
        return 1;
      }

      DebuggingOptions options;


      if (getBuildMode() == BuildMode.release) {
        options = new DebuggingOptions.disabled(getBuildMode());
      } else {
        options = new DebuggingOptions.enabled(
          getBuildMode(),
          startPaused: argsMap['start-paused'],
          observatoryPort: debugPort
        );
      }

      Cache.releaseLockEarly();

      // Enable hot mode by default if ``--no-hot` was not passed and we are in
      // debug mode.
      final bool hotMode = true; //shouldUseHotMode();

      if (hotMode) {
        if (!device.supportsHotMode) {
          printError('Hot mode is not supported by this device. '
                     'Run with --no-hot.');
          return 1;
        }
      }

      String pidFile = argsMap['pid-file'];
      if (pidFile != null) {
        // Write our pid to the file.
        new File(pidFile).writeAsStringSync(pid.toString());
      }
      ResidentRunner runner;

      if (hotMode) {
        runner = new HotRunner(
          device,
          target: targetFile,
          debuggingOptions: options,
          benchmarkMode: argsMap['benchmark'],
        );

        hotRunner = runner;
      } else {
        runner = new RunAndStayResident(
          device,
          target: targetFile,
          debuggingOptions: options,
          traceStartup: traceStartup,
          benchmark: argsMap['benchmark'],
          applicationBinary: argsMap['use-application-binary']
        );
      }

      return runner.run(route: route, shouldBuild: argsMap['build']);
    }
  }

//
//   @override
//   Future<int> runInProject() async {
//     int debugPort;
//     if (deviceForCommand.isLocalEmulator && !isEmulatorBuildMode(buildMode)) {
//       printError('${toTitleCase(getModeName(buildMode))} mode is not supported for emulators.');
//       return 1;
//     }
//
//     DebuggingOptions options;
//
//
//     if (buildMode == BuildMode.release) {
//       options = new DebuggingOptions.disabled(buildMode);
//     } else {
//       options = new DebuggingOptions.enabled(
//         buildMode,
//         startPaused: startPaused_arg,
//         observatoryPort: debugPort
//       );
//     }
//
//     printTrace("about to release lock on cache");
//
//     Cache.releaseLockEarly();
//
//     // Do some early error checks for hot mode.
//     bool hotMode = hot_arg;
//
//     if (hotMode) {
//       if (buildMode != BuildMode.debug) {
//         printError('Hot mode only works with debug builds.');
//         return 1;
//       }
//       if (!deviceForCommand.supportsHotMode) {
//         printError('Hot mode is not supported by this device.');
//         return 1;
//       }
//     }
//
//     String pidFile = pidFile_arg;
//     if (pidFile != null) {
//       // Write our pid to the file.
//       new File(pidFile).writeAsStringSync(pid.toString());
//     }
//     ResidentRunner runner;
//
//     if (hot_arg) {
//       runner = new HotRunner(
//         deviceForCommand,
//         target: targetFile,
//         debuggingOptions: options
//       );
//     } else {
//       runner = new RunAndStayResident(
//         deviceForCommand,
//         target: targetFile,
//         debuggingOptions: options,
//         traceStartup: traceStartup,
//         benchmark: null, //argResults['benchmark'],
//         applicationBinary: null //argResults['use-application-binary']
//       );
//     }
//
//     print ("Calling runner with route: $route");
//     print ("Runner type: ${runner.runtimeType}");
//
//     vmService = runner.vmService;
//     return runner.run(route: route, shouldBuild: build_arg);
//     return  result;
//   }
// }
