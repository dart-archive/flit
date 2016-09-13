import 'dart:io' as io;

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:path/path.dart' as path;

String basePath;

main(List<String> args) async {

  if (args.length == 0) {
    basePath = path.join(io.Directory.current.path, "ui");
  }

  var staticHandler = createStaticHandler(basePath, defaultDocument:'index.html');

  var opGetHandler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(_opGetHandler);

  var myRouter = router()
    ..get('/services', opGetHandler);
      // ..get('/services{?op}', opGetHandler);

  var handler = new shelf.Cascade()
       .add(staticHandler)
       .add(myRouter.handler)
       .handler;

  var server = await shelf_io.serve(handler, 'localhost', 9000);

  // Enable content compression
  server.autoCompress = true;

  print('Serving at http://${server.address.host}:${server.port}');
}

shelf.Response _opGetHandler(shelf.Request request) {
  var uri = request.requestedUri;

 var params = getPathParameters(request);
  return new shelf.Response.ok('Request for uri:$uri $params');
}
