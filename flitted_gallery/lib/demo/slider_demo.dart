// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class SliderDemo extends StatefulWidget {
  static const String routeName = '/slider';

  @override
  _SliderDemoState createState() => new _SliderDemoState();
}

class _SliderDemoState extends State<SliderDemo> {
  double _value = 25.0;
  double _discreteValue = 20.0;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Sliders')),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget> [
              new Slider(
                value: _value,
                min: 0.0,
                max: 100.0,
                onChanged: (double value) {
                  setState(() {
                    _value = value;
                  });
                }
              ),
              new Text('Continuous'),
            ]
          ),
          new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget> [
              new Slider(value: 0.25, onChanged: null),
              new Text('Disabled'),
            ]
          ),
          new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget> [
              new Slider(
                value: _discreteValue,
                min: 0.0,
                max: 100.0,
                divisions: 5,
                label: '${_discreteValue.round()}',
                onChanged: (double value) {
                  setState(() {
                    _discreteValue = value;
                  });
                }
              ),
              new Text('Discrete'),
            ]
          ),
        ]
      )
    );
  }
}
