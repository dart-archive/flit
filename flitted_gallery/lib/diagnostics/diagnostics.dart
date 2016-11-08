// Copyright 2016 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'visiting.dart';

/// [globalState] must be initialized on startup by the application
/// so that [updateHighlightIds] can refresh the current view
State globalState;

Set<int> highlightIds = new Set<int>();

/// Update the highlight and refresh the view.
Future<Null> updateHighlightIds(List<int> newValues) async {
  globalState.setState(() {
    highlightIds.clear();
    highlightIds.addAll(newValues);
  });
}

// TODO: modify the objects to that they accept a const parameter
// listing their ctor callsite
// The current implementation will leak objects that aren't on the canvas
// but aren't replaced
Map<int, Map<String, Object>> originMap = {};

registerWithOriginMap(id, widget) {
  var location = new SourceLocation("/dummy.dart", 0, 0);

  // serialize and send originMap over wire to laptop
  // using the VM service protocol
  originMap[id] = {
    "path": location.path.split("/").last, // Friendly path
    "line": location.line,
    "char": location.char,
    "widgetName": "${widget.runtimeType}",
  };
}

Widget h(id, Widget w) {
  Stopwatch sw = new Stopwatch()..start();
  registerWithOriginMap(id, w);
  String widgetName = w.runtimeType.toString();
  if (highlightIds.contains(id)) {
    w = new CustomPaint(child: w, foregroundPainter: new HighlightPainter());
  }
  print ("${sw.elapsedMilliseconds} Widget: $id $widgetName");
  return w;
}

class HighlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = new Paint()
      ..color = Colors.red[500].withOpacity(0.40)
      ..style = PaintingStyle.fill
      ..strokeWidth = 5.0;
    canvas.drawRRect(
        new RRect.fromRectAndCorners(
            new Rect.fromLTWH(-5.0, -5.0, size.width + 10.0, size.height + 10.0),
            topLeft: new Radius.circular(2.0),
            topRight: new Radius.circular(2.0),
            bottomLeft: new Radius.circular(2.0),
            bottomRight: new Radius.circular(2.0)
        ), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SourceLocation {
  final String path;
  final int line;
  final int char;

  const SourceLocation(this.path, this.line, this.char);
  toString() => "$path:$line:$char";
}

/**
 * Placeholder method to repeatedly extract the annotated tree
 */
Timer t;
diagnosticsStart() {
  print ("Diagnostics start");

  t = new Timer.periodic(new Duration(seconds: 1),(_) async {
    print ("tick");
    await debugReturnWidgetTreeAnnotated({});
  });
}
