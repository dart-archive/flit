import 'package:flutter/material.dart';

List<int> highlightIds = [4];

dynamic e(dynamic d) {
  var st = StackTrace.current;
  originMap[d] = st;
  return d;
}

Map originMap = {}; // TODO this will pin all UI elements for all of history


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
