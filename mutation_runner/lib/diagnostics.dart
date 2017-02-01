// Copyright 2016 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

/// [globalState] must be initialized on startup by the application
/// so that [updateHighlightIds] can refresh the current view
State globalState;

/// The ids of the highlighted widgets
List<int> highlightIds = [];

/// Update the highlight and refresh the view.
Future<Null> updateHighlightIds(List<int> newValues) async {
  globalState.setState(() {
    highlightIds = newValues;
  });
}

/// Register the specified widget.
/// If [highlightIds] contains [id] then also highlight that widget.
Widget h(int id, BuildContext context, Widget w) {
  _registerWithOriginMap(id, w);
  debugPaintPointersEnabled = true;
  if (highlightIds.contains(id)) {
    // Delay highlighting until after the render objects have been built
    new Future(() => _highlight(id, w, context));
  } else {
    _unhighlight(id);
  }
  return w;
}

/// Mapping of widget id's to highlighted render objects
Map<int, RenderBox> _highlighted = <int, RenderBox>{};

/// Find and highlight the render object associated with the given widget.
void _highlight(int id, Widget w, BuildContext context) {
  if (w != context.widget) {
    context.visitChildElements((Element child) {
      _highlight(id, w, child);
    });
    return;
  }
  if (context is Element) {
    RenderObject renderObject = context.renderObject;
    if (renderObject is RenderBox) {
      renderObject.debugHandleEvent(
          new PointerDownEvent(), new HitTestEntry(null));
      _highlighted[id] = renderObject;
    }
  }
}

void _unhighlight(int id) {
  (_highlighted.remove(id))
      ?.debugHandleEvent(new PointerCancelEvent(), new HitTestEntry(null));
}

// TODO: modify the objects to that they accept a const parameter
// listing their ctor callsite
// The current implementation will leak objects that aren't on the canvas
// but aren't replaced
Map<int, Map<String, Object>> originMap = {};

_registerWithOriginMap(int id, Widget widget) {
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
