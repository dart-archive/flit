import 'dart:io' as io;
import 'dart:async';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:path/path.dart' as path;

import 'package:flutter_tools/src/device.dart';
import 'package:flutter_tools/src/doctor.dart';
import 'package:flutter_tools/src/base/context.dart';
import 'package:flutter_tools/src/base/logger.dart';

import 'package:flutter_tools/src/vmservice.dart';


String basePath;

main(List<String> args) async {
  if (args.length == 0) {
    basePath = path.join(io.Directory.current.path, "ui");
  }

  var staticHandler =
      createStaticHandler(basePath, defaultDocument: 'index.html');

  var opGetHandler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_opGetHandler);

  var myRouter = router()..get('/services', opGetHandler);
  // ..get('/services{?op}', opGetHandler);

  var handler =
      new shelf.Cascade().add(staticHandler).add(myRouter.handler).handler;

  var server = await shelf_io.serve(handler, 'localhost', 9000);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

Future<shelf.Response> _opGetHandler(shelf.Request request) async {
  if (!hasSetupRun) _setup();

  var uri = request.requestedUri;
  var params = getPathParameters(request);
  // return new shelf.Response.ok('Request for uri:$uri $params');
  return new shelf.Response.ok(await _listDevices(request));
}

var hasSetupRun = false;
_setup() {
  // Initialize globals.
  context[Logger] = new StdoutLogger();
  context[DeviceManager] = new DeviceManager();
  Doctor.initGlobal();
  hasSetupRun = true;
}

dynamic _listDevices(shelf.Request request) async {
  DeviceManager dm = context[DeviceManager];
  var devices = await dm.getDevices();
  return "$devices";
}

dynamic _run(shelf.Request request) async {
  DeviceManager dm = context[DeviceManager];
  var devices = await dm.getDevices();
  // devices.first.installApp();
  return "$devices";
}
