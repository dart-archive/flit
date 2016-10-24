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
import 'package:flutter_tools/src/resident_runner.dart';
import 'package:path/path.dart' as path;
import 'package:vm_service_client/vm_service_client.dart';

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
  VMServiceClient vmClient =
      new VMServiceClient.connect('http://127.0.0.1:${debugInfo.port}');

  var m = hotRunner.currentView.uiIsolate.flutterDebugReturnElementTree();
  print(await m);

  // Load the originMap and highlightIds from the running application
  VMIsolateRef isolateRef = await vmClient.onIsolateStart.first;
  VMRunnableIsolate isolate = await isolateRef.loadRunnable();
  Map<Uri, VMLibraryRef> libraries = isolate.libraries;
  VMLibraryRef libRef = libraries[libraries.keys
      .firstWhere((Uri url) => url.path.endsWith('/lib/diagnostics.dart'))];
  VMLibrary lib = await libRef.load();
  Map originMap = await loadRef(lib.fields['originMap']);
  var highlightIds = await loadRef(lib.fields['highlightIds']);

  // Delay before printing to prevent text collision in console
  new Future.delayed(new Duration(seconds: 5)).then((_) {
    print('originMap = $originMap}');
    print('highlightIds = $highlightIds');
  });

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
        if (running) watchDiagFile();
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
