// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../diagnostics.dart';

class PageSelectorDemo extends StatelessWidget {

  static const String routeName = '/page-selector';

  void _handleArrowButtonPress(BuildContext context, int delta) {
    final TabBarSelectionState<IconData> selection = TabBarSelection.of/*<IconData>*/(context);
    if (!selection.valueIsChanging)
      selection.value = selection.values[(selection.index + delta).clamp(0, selection.values.length - 1)];
  }

  @override
  Widget build(BuildContext notUsed) { // Can't find the TabBarSelection from this context.
    final List<IconData> icons = <IconData>[
      Icons.event,
      Icons.home,
      Icons.android,
      Icons.alarm,
      Icons.face,
      Icons.language,
    ];

    return new Scaffold(
      appBar: new AppBar(title: new Text('Page selector')),
      body: new TabBarSelection<IconData>(
        values: icons,
        child: new Builder(
          builder: (BuildContext context) {
            final Color color = Theme.of(context).accentColor;
            return new Column(
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  child: new Row(
                    children: <Widget>[
                      new IconButton(
                        icon: new Icon(Icons.chevron_left),
                        color: color,
                        onPressed: () { _handleArrowButtonPress(context, -1); },
                        tooltip: 'Page back'
                      ),
                      new TabPageSelector<IconData>(),
                      new IconButton(
                        icon: new Icon(Icons.chevron_right),
                        color: color,
                        onPressed: () { _handleArrowButtonPress(context, 1); },
                        tooltip: 'Page forward'
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween
                  )
                ),
                new Flexible(
                  child: new TabBarView<IconData>(
                    children: icons.map((IconData icon) {
                      return new Container(
                        key: new ObjectKey(icon),
                        padding: const EdgeInsets.all(12.0),
                        child: new Card(
                          child: new Center(
                            child: new Icon(icon, size: 128.0, color: color)
                          )
                        )
                      );
                    })
                    .toList()
                  )
                )
              ]
            );
          }
        )
      )
    );
  }
}
