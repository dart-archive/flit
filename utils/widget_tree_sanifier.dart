// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Take a file containing an output of the widget tree export and objectify it
// by doing text munging

import 'dart:io' as io;
import 'dart:convert';

Map structure = {};
Map<int, Map> lastAtLevelMap = {};

main(List<String> args) {
  String path = args[0];

  List<String> lines = new io.File(path).readAsLinesSync();

  // Ignore the first line
  if (lines.first.endsWith("WidgetsFlutterBinding - CHECKED MODE")) {
    lines.removeAt(0);
  }

  // Strip prefix from all of the lines
  lines = lines.map((ln) => ln.substring("I/flutter : ".length)).toList();

  for (String ln in lines) {
    var firstChar = firstNameChar(ln);
    int level = (firstChar / 2).floor();
    Map item = {
      "Name" : ln.substring(firstChar),
      "Children" : []
    };
    lastAtLevelMap[level] = item;

    // Find the item at the level before this
    if (level == 0) {
      structure[0] = item;
    } else {
      lastAtLevelMap[level-1]["Children"].add(item);
    }
  }

  print (structure);
}

int firstNameChar(String ln) => ln.indexOf(new RegExp(r'[a-zA-Z_]'));
