import 'package:flutter/material.dart';

List elems = [];
BuildContext savedContext;

void main() {
  runApp(
    new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new FlutterDemo(),
    ),
  );

  print(savedContext);
}

class FlutterDemo extends StatefulWidget {
  FlutterDemo({ Key key }) : super(key: key);

  @override
  _FlutterDemoState createState() => new _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counter = 0;

  void mapElementTree(Element e) {
    mapElement(e);
    e.visitChildren(mapElementTree);
  }

  void _incrementCounter() {
    savedContext.visitChildElements(collectElements);
    setState(() {
      _counter = elems.length;
    });
    elems = [];
  }

  void collectElements(Element e){
    elems.add(e);
    e.visitChildren(collectElements);
  }

  setSavedContext(c) {
    if (savedContext == null) { savedContext = c;}
  }

  @override
  Widget build(BuildContext context) {
    var tree = new Scaffold(
      appBar: new AppBar(
        title: new Text('Flutter Demo'),
      ),
      body: new Center(
        child: new Text('Our Button tapped $_counter time${ _counter == 1 ? '' : 's' }.'),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: new Icon(Icons.add),
      ),
    );
    setSavedContext(context);
    return tree;
  }
}
