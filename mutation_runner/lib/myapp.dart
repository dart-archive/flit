// Copyright 2016 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

//import 'visting.dart';
import 'diagnostics.dart';

BuildContext savedContext;

void main() {
  runApp(
    new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FlutterDemo(
      ),
    )
  );
}

String computeText() {
  StringBuffer sb = new StringBuffer();

  List<int> originKeys = originMap.keys.toList()..sort();
  for (var id in originKeys) {
    Map mp = originMap[id];
    sb.writeln("$id ${mp["widgetName"]} ${mp["path"]} ${mp["line"]}:${mp["char"]}");
  }
 return sb.toString();
}

class FlutterDemo extends StatefulWidget {
  FlutterDemo({ Key key }) : super(key: key);

  @override
  _FlutterDemoState createState() {
    return globalState = new _FlutterDemoState();
  }
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter = _counter + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    var tree = h(0, context, new Scaffold(
      appBar: h(1, context, new AppBar(
        title: h(2, context, new Text('Flutter Demo')),

      )),
      body: h(3, context, new Center(
        child: h(4, context, new Text("${computeText()}")),
//        child: h(4, context, new Text("test")),
      )),
      floatingActionButton: h(5, context, new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: h(6, context, new Icon(Icons.add)),
      )),
    ));
    return tree;
  }
}
