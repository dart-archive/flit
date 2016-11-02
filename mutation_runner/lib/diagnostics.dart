import 'dart:async';

import 'package:flutter/material.dart';

/// [globalState] must be initialized on startup by the application
/// so that [updateHighlightIds] can refresh the current view
State globalState;

List<int> highlightIds = [5];

/// Update the highlight and refresh the view.
Future<Null> updateHighlightIds(List<int> newValues) async {
  globalState.setState(() {
    highlightIds = newValues;
  });
}

// TODO: modify the objects to that they accept a const parameter
// listing their ctor callsite
// The current implementation will leak objects that aren't on the canvas
// but aren't replaced
Map<int, Map<String, Object>> originMap = {};

registerWithOriginMap(id, widget) {
  var st = StackTrace.current;
  var location = _extractHLocation(st);

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
  registerWithOriginMap(id, w);
  if (!highlightIds.contains(id)) return w;
  return new CustomPaint(child: w, foregroundPainter: new HighlightPainter());
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

// There doesn't seem to be a way of programmatically manipulating the stack
// trace objects so we fall back to string manipulation
SourceLocation _extractHLocation(StackTrace st) {

  List<String> lines = st.toString().split("\n");
  String diagnosticsCallsite = lines[2].trim();
  String locationBlock = diagnosticsCallsite.split(" ").last;
  locationBlock = locationBlock.substring(1); // Strip leading '('
  List<String> segmentSplit = locationBlock.split(":");

  String path = segmentSplit[0];
  int line = int.parse(segmentSplit[1]);
  int char = int.parse(segmentSplit[2].split(")").first);

  return new SourceLocation(path, line, char);
}

class SourceLocation {
  final String path;
  final int line;
  final int char;

  const SourceLocation(this.path, this.line, this.char);
  toString() => "$path:$line:$char";
}