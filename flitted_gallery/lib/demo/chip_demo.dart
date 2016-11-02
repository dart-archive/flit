// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../diagnostics.dart';

class ChipDemo extends StatefulWidget {
  static const String routeName = '/chip';

  @override
  _ChipDemoState createState() => new _ChipDemoState();
}

class _ChipDemoState extends State<ChipDemo> {
  bool _showBananas = true;

  void _deleteBananas() {
    setState(() {
      _showBananas = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> chips = <Widget>[
      new Chip(
        label: new Text('Apple')
      ),
      new Chip(
        avatar: new CircleAvatar(child: new Text('B')),
        label: new Text('Blueberry')
      ),
    ];

    if (_showBananas) {
      chips.add(new Chip(
        label: new Text('Bananas'),
        onDeleted: _deleteBananas
      ));
    }

    return new Scaffold(
      appBar: new AppBar(title: new Text('Chips')),
      body: new Block(
        children: chips.map((Widget widget) {
          return new Container(
            height: 100.0,
            child: new Center(child: widget)
          );
        }).toList()
      )
    );
  }
}
