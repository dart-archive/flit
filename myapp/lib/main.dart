import 'package:flutter/material.dart';
import 'visting.dart';

BuildContext savedContext;

void main() {
  stack = [
    {'children': []}
  ];
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

  print(savedContext);
}

String banner() {
  if (savedContext == null) {
    return 'Button';
  }
  return top()['children'].toString();
}

class FlutterDemo extends StatefulWidget {
  FlutterDemo({ Key key }) : super(key: key);

  @override
  _FlutterDemoState createState() => new _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counter = 0;

  void _incrementCounter() {
    stack = [
      {'children': []}
    ];
    savedContext.visitChildElements(elementCollector);
    setState(() {
      _counter = _counter + 1;
    });
  }

  setSavedContext(c) {
    if (savedContext == null) { savedContext = c;}
  }

  @override
  Widget build(BuildContext context) {
    var tree = e(new Scaffold(
      appBar: e(new AppBar(
        title: e(new Text('Flutter Demo')),

      )),
      body: e(new Center(
        child: e(new Text('Our ' + banner() +' tapped $_counter time${ _counter == 1 ? '' : 's' }.')),

      )),
      floatingActionButton: e(new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: e(new Icon(Icons.add)),
      )),
    ));
    setSavedContext(context);
    return tree;
  }
}


dynamic e(dynamic d) {
  print (StackTrace.current);
  return d;
}
