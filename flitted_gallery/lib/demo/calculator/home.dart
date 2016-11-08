// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'logic.dart';

import '../../diagnostics.dart';

class Calculator extends StatefulWidget {
  Calculator({Key key}) : super(key: key);

  @override
  _CalculatorState createState() => new _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  /// As the user taps keys we update the current `_expression` and we also
  /// keep a stack of previous expressions so we can return to earlier states
  /// when the user hits the DEL key.
  final List<CalcExpression> _expressionStack = <CalcExpression>[];
  CalcExpression _expression = new CalcExpression.Empty();

  // Make `expression` the current expression and push the previous current
  // expression onto the stack.
  void pushExpression(CalcExpression expression) {
    _expressionStack.add(_expression);
    _expression = expression;
  }

  /// Pop the top expression off of the stack and make it the current expression.
  void popCalcExpression() {
    if (_expressionStack.length > 0) {
      _expression = _expressionStack.removeLast();
    } else {
      _expression = new CalcExpression.Empty();
    }
  }

  /// Set `resultExpression` to the currrent expression and clear the stack.
  void setResult(CalcExpression resultExpression) {
    _expressionStack.clear();
    _expression = resultExpression;
  }

  void handleNumberTap(int n) {
    final CalcExpression expression = _expression.appendDigit(n);
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handlePointTap() {
    final CalcExpression expression = _expression.appendPoint();
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handlePlusTap() {
    final CalcExpression expression = _expression.appendOperation(Operation.Addition);
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handleMinusTap() {
    final CalcExpression expression = _expression.appendMinus();
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handleMultTap() {
    final CalcExpression expression = _expression.appendOperation(Operation.Multiplication);
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handleDivTap() {
    final CalcExpression expression = _expression.appendOperation(Operation.Division);
    if (expression != null) {
      setState(() {
        pushExpression(expression);
      });
    }
  }

  void handleEqualsTap() {
    final CalcExpression resultExpression = _expression.computeResult();
    if (resultExpression != null) {
      setState(() {
        setResult(resultExpression);
      });
    }
  }

  void handleDelTap() {
    setState(() {
      popCalcExpression();
    });
  }

  @override
  Widget build(BuildContext context) {
    return h(1000, new Scaffold(
      appBar: h(1001, new AppBar(
        backgroundColor: Theme.of(context).canvasColor,
        elevation: 0
      )),
      body: h(1002, new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Give the key-pad 3/5 of the vertical space and the display 2/5.
          h(1003, new Flexible(
            flex: 2,
            child: h(1004, new CalcDisplay(content: _expression.toString()))
          )),
          h(1005, new Divider(height: 1.0)),
          h(1006, new Flexible(
            flex: 3,
            child: h(1007, new KeyPad(calcState: this))
          ))
        ]
      ))
    ));
  }
}

class CalcDisplay extends StatelessWidget {
  CalcDisplay({ this.content });

  final String content;

  @override
  Widget build(BuildContext context) {
    return h(1008, new Center(
      child: h(1009, new Text(
        content,
        style: const TextStyle(fontSize: 24.0)
      ))
    ));
  }
}

class KeyPad extends StatelessWidget {
  KeyPad({ this.calcState });

  final _CalculatorState calcState;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = new ThemeData(
      primarySwatch: Colors.purple,
      brightness: Brightness.dark,
      platform: Theme.of(context).platform,
    );
    return h(1010, new Theme(
      data: themeData,
      child: h(1011, new Material(
        child: h(1012, new Row(
          children: <Widget>[
            h(1013, new Flexible(
              // We set flex equal to the number of columns so that the main keypad
              // and the op keypad have sizes proportional to their number of
              // columns.
              flex: 3,
              child: h(1014, new Column(
                children: <Widget>[
                  h(1015, new KeyRow(<Widget>[
                    h(1016, new NumberKey(7, calcState)),
                    h(1017, new NumberKey(8, calcState)),
                    h(1018, new NumberKey(9, calcState))
                  ])),
                  h(1019, new KeyRow(<Widget>[
                    h(1020, new NumberKey(4, calcState)),
                    h(1021, new NumberKey(5, calcState)),
                    h(1022, new NumberKey(6, calcState))
                  ])),
                  h(1023, new KeyRow(<Widget>[
                    h(1024, new NumberKey(1, calcState)),
                    h(1025, new NumberKey(2, calcState)),
                    h(1026, new NumberKey(3, calcState))
                  ])),
                  h(1027, new KeyRow(<Widget>[
                    h(1028, new CalcKey('.', calcState.handlePointTap)),
                    h(1029, new NumberKey(0, calcState)),
                    h(1030, new CalcKey('=', calcState.handleEqualsTap)),
                  ]))
                ]
              ))
            )),
            h(1031, new Flexible(
              child: h(1032, new Material(
                color: themeData.backgroundColor,
                child: h(1033, new Column(
                  children: <Widget>[
                    h(1034, new CalcKey('\u232B', calcState.handleDelTap)),
                    h(1035, new CalcKey('\u00F7', calcState.handleDivTap)),
                    h(1036, new CalcKey('\u00D7', calcState.handleMultTap)),
                    h(1037, new CalcKey('-', calcState.handleMinusTap)),
                    h(1038, new CalcKey('+', calcState.handlePlusTap))
                  ]
                ))
              ))
            )),
          ]
        ))
      ))
    ));
  }
}

class KeyRow extends StatelessWidget {
  KeyRow(this.keys);

  final List<Widget> keys;

  @override
  Widget build(BuildContext context) {
    return h(1039, new Flexible(
      child: h(1040, new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: this.keys
      ))
    ));
  }
}

class CalcKey extends StatelessWidget {
  CalcKey(this.text, this.onTap);

  final String text;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return h(1041, new Flexible(
      child: h(1042, new InkResponse(
        onTap: this.onTap,
        child: h(1043, new Center(
          child: h(1044, new Text(
            this.text,
            style: new TextStyle(
              fontSize: (orientation == Orientation.portrait) ? 32.0 : 24.0
            )
          ))
        ))
      ))
    ));
  }
}

class NumberKey extends CalcKey {
  NumberKey(int value, _CalculatorState calcState)
    : super('$value', () {
        calcState.handleNumberTap(value);
      });
}
