// Copyright 2016 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:io' as io;
import 'dart:async';
import 'dart:convert';

import 'package:flutter_tools/src/base/common.dart';
import 'package:flutter_tools/src/build_info.dart';
import 'package:flutter_tools/src/cache.dart';
import 'package:flutter_tools/src/device.dart';
import 'package:flutter_tools/src/doctor.dart';
import 'package:flutter_tools/src/base/context.dart';
import 'package:flutter_tools/src/base/logger.dart';
import 'package:flutter_tools/src/globals.dart';
import 'package:flutter_tools/src/hot.dart';
import 'package:flutter_tools/src/resident_runner.dart';
import 'package:path/path.dart' as path;
import 'package:vm_service_client/vm_service_client.dart';


const DIAGNOSTICS_PATH = '/lib/diagnostics.dart';

main(List<String> args) async {
  String flutterRoot = '../../GitRepos/flutter';
  String target = "lib/myapp.dart";
  String route = "/";
  String diagPath = "lib/diagnostics.dart";
  const int SERVER_PORT = 9998;

  // Initialize globals.
  Cache.flutterRoot = path.normalize(path.absolute(flutterRoot));
  context[Logger] = new StdoutLogger();
  context[DeviceManager] = new DeviceManager();
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
  VMServiceClient vmClient =
      new VMServiceClient.connect('http://127.0.0.1:${debugInfo.port}');
  VMIsolateRef isolateRef = await vmClient.onIsolateStart.first;

  await setHighlights(isolateRef, []);

  // Server based requests

  var requestServer =
    await io.HttpServer.bind(io.InternetAddress.LOOPBACK_IP_V4, SERVER_PORT);
  print('listening on localhost, port ${requestServer.port}');

  await for (io.HttpRequest request in requestServer) {
    addCorsHeaders(request.response);
    print ("${request.method} ${request.uri.path}");

    switch (request.uri.path) {
      case "/getIds":
        Map idMap = await getIds(isolateRef);
        Map jsonSafeMap = {};
        idMap.forEach((k, v) {
          jsonSafeMap["$k"] = v;
        });

        request.response..write(await JSON.encode(jsonSafeMap))..close();
        break;
      case "/setHighlights":
        String requestBody = await request.transform(UTF8.decoder).join();
        print ("Setting Highlights: $requestBody");
        List ids = JSON.decode(requestBody);
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
  print('originMap = $originMap}');
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
  return obj.runtimeType;
}

/// Update the highlightIds and pull new values from the Flutter app
Future<List> updateHighlightIds(VMFieldRef fieldRef, List newValues) async {
  String expression = 'updateHighlightIds([${newValues.join(',')}]);';
  print('Evaluating: $expression');
  VMLibraryRef libRef = fieldRef.owner;
  VMInstanceRef result = await libRef.evaluate(expression);
  List remoteValues = await loadRef(result);
  print('   = ${remoteValues}');
  remoteValues = await loadRef(fieldRef);
  print('   = ${remoteValues}');
  return remoteValues;
}

// Server support methods
void addCorsHeaders(io.HttpResponse res) {
  res.headers.add("Access-Control-Allow-Origin", "*");
  res.headers.add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
  res.headers.add("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
}
