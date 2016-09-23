import 'package:flutter/material.dart';
import 'visting.dart';
import 'diagnostics.dart';

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
    var tree = h(0, new Scaffold(
      appBar: h(1, new AppBar(
        title: h(2, new Text('Flutter Demo')),

      )),
      body: h(3, new Center(
        child: h(4, new Text('Our ' + banner() +' tapped $_counter time${ _counter == 1 ? '' : 's' }.')),

      )),
      floatingActionButton: h(5, new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: h(6, new Icon(Icons.add)),
      )),
    ));
    setSavedContext(context);

    return tree;
  }
}

Widget h(id, Widget w) {
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

List<int> highlightIds = [4];
