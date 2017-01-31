// Copyright 2016 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:io' as io;
import 'dart:async';
import 'dart:convert';

import 'package:file/local.dart';
import 'package:flutter_tools/src/base/common.dart';
import 'package:flutter_tools/src/base/context.dart';
import 'package:flutter_tools/src/base/file_system.dart';
import 'package:flutter_tools/src/base/logger.dart';
import 'package:flutter_tools/src/base/os.dart';
import 'package:flutter_tools/src/build_info.dart';
import 'package:flutter_tools/src/cache.dart';
import 'package:flutter_tools/src/device.dart';
import 'package:flutter_tools/src/doctor.dart';
import 'package:flutter_tools/src/run_hot.dart';
import 'package:flutter_tools/src/ios/mac.dart';
import 'package:flutter_tools/src/ios/simulators.dart';
import 'package:flutter_tools/src/resident_runner.dart';
import 'package:flutter_tools/src/toolchain.dart';
import 'package:flutter_tools/src/usage.dart';
import 'package:path/path.dart' as path;
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:vm_service_client/vm_service_client.dart';


const DIAGNOSTICS_PATH = '/lib/diagnostics.dart';

main(List<String> args) async {
  new AppContext().runInZone(_runInZone, onError: (e, s) {
    print('============================');
    print(e);
    print(s);
  });
}

_runInZone() async {
  String flutterRoot = '../../flutter';
  String target = "lib/myapp.dart";
  String route = "/";
  String diagPath = "lib/diagnostics.dart";
  const int SERVER_PORT = 9998;

  // Initialize globals.
  Cache.flutterRoot = path.normalize(path.absolute(flutterRoot));

  // Seed these context entries first since others depend on them
  context.putIfAbsent(Platform, () => new LocalPlatform());
  context.setVariable(FileSystem, new LocalFileSystem());
  context.setVariable(ProcessManager, new LocalProcessManager());
  context.setVariable(Logger, new StdoutLogger());

  // Order-independent context entries
  context.setVariable(Cache, new Cache());
  context.setVariable(DeviceManager, new DeviceManager());
  context.setVariable(HotRunnerConfig, new HotRunnerConfig());
  context.setVariable(IOSSimulatorUtils, new IOSSimulatorUtils());
  context.setVariable(OperatingSystemUtils, new OperatingSystemUtils());
  context.setVariable(SimControl, new SimControl());
  context.setVariable(ToolConfiguration, new ToolConfiguration());
  context.setVariable(Usage, new Usage());
  context.setVariable(XCode, new XCode());
  context.setVariable(Doctor, new Doctor());

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
  VMServiceClient vmClient = new VMServiceClient.connect(debugInfo.wsUri);
  var vm = await vmClient.getVM();
  var isolates = vm.isolates;
  VMIsolateRef isolateRef;
  if (isolates.isNotEmpty) {
    isolateRef = isolates[0];
  } else {
    isolateRef = await vmClient.onIsolateStart.first;
  }

  await setHighlights(isolateRef, []);

  // Server based requests

  var requestServer =
    await io.HttpServer.bind(io.InternetAddress.LOOPBACK_IP_V4, SERVER_PORT);
  print(
    '\n==============================='
    '\nlistening on localhost, port ${requestServer.port}'
    '\n===============================');

  await for (io.HttpRequest request in requestServer) {
    addCorsHeaders(request.response);
    print ("${request.method} ${request.uri.path}");

    Uri uri = request.uri;
    switch (uri.path) {
      case "/getIds":
        Map idMap = await getIds(isolateRef);
        Map jsonSafeMap = {};
        idMap.forEach((k, v) {
          jsonSafeMap["$k"] = v;
        });

        request.response..write(await JSON.encode(jsonSafeMap))..close();
        break;
      case "/setHighlights":
        var text = uri.queryParameters['h'];
        if (text == null) {
          text = await request.transform(UTF8.decoder).join();
        }
        print ("Setting Highlights: $text");
        var json = JSON.decode(text);
        List ids = json is int ? [json] : json;
        setHighlights(isolateRef, ids);
        request.response..writeln("Done")..close();
        break;
    }
  }
}

// UI Support methods


setHighlights(VMIsolateRef isolateRef, List<int> highlightIds) async {
  VMLibrary lib = await _getLibrary(isolateRef, DIAGNOSTICS_PATH);
  VMFieldRef highlightIdsField = lib.fields['highlightIds'];
  Map originMap = await loadRef(lib.fields['originMap']);
  List existinghighlightIds = await loadRef(highlightIdsField);

  // Delay before printing to prevent text collision in console
  print('originMap = ');
  var keys = originMap.keys.toList()..sort();
  for (var k in keys) {
    print('  $k : ${originMap[k]}');
  }
  print('}');
  print('highlightIds = $existinghighlightIds');

  await updateHighlightIds(highlightIdsField, highlightIds);

}

Future<Map> getIds(VMIsolateRef isolateRef) async {
  VMLibrary lib = await _getLibrary(isolateRef, DIAGNOSTICS_PATH);
  Map originMap = await loadRef(lib.fields['originMap']);
  return originMap;
}


// VM Support methods

Future<VMLibrary> _getLibrary(VMIsolateRef isolateRef, String name) async {
  VMRunnableIsolate isolate = await isolateRef.loadRunnable();
  Map<Uri, VMLibraryRef> libraries = isolate.libraries;
  VMLibraryRef libRef = libraries[libraries.keys
      .firstWhere((Uri url) => url.path.endsWith(name))];
  VMLibrary lib = await libRef.load();
  return lib;
}

/// Recursively load the specified object from the VM.
Future<dynamic> loadRef(VMObjectRef ref) async {
  var obj = await ref.load();
  if (obj is VMValueInstance) return obj.value;
  if (obj is VMStringInstance) return obj.value;
  if (obj is VMListInstance) {
    List list = [];
    for (var elem in obj.elements) {
      if (elem is VMObjectRef) {
        list.add(await loadRef(elem));
      } else if (elem is VMSentinel) {
        list.add(elem.toString());
      } else {
        list.add(elem);
      }
    }
    return list;
  }
  if (obj is VMMapInstance) {
    Map map = {};
    for (VMMapAssociation assoc in obj.associations) {
      map[await loadRef(assoc.key)] = await loadRef(assoc.value);
    }
    return map;
  }
  if (obj is VMField) return loadRef(obj.value);
  print('Unknown ref, returning String instead: "$obj"');
  return '$obj';
}

/// Update the highlightIds and pull new values from the Flutter app
Future<List> updateHighlightIds(VMFieldRef fieldRef, List newValues) async {
  String expression = 'updateHighlightIds([${newValues.join(',')}]);';

  print('Evaluating: $expression');
  VMLibraryRef libRef = fieldRef.owner;
  var result = await libRef.evaluate(expression);
  var loadResult = await loadRef(result);
  print('   = ${loadResult}');
  List remoteValues = await loadRef(fieldRef);
  print('   = ${remoteValues}');
  return remoteValues;
}

// Server support methods
void addCorsHeaders(io.HttpResponse res) {
  res.headers.add("Access-Control-Allow-Origin", "*");
  res.headers.add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
  res.headers.add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
}
