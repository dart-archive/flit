// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import '../diagnostics.dart';

class TwoLevelListDemo extends StatelessWidget {
  static const String routeName = '/two-level-list';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Expand/collapse list control')),
      body: new TwoLevelList(
        type: MaterialListType.oneLine,
        children: <Widget>[
          new TwoLevelListItem(title: new Text('Top')),
          new TwoLevelSublist(
             title: new Text('Sublist'),
             backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
             children: <Widget>[
               new TwoLevelListItem(title: new Text('One')),
               new TwoLevelListItem(title: new Text('Two')),
               // https://en.wikipedia.org/wiki/Free_Four
               new TwoLevelListItem(title: new Text('Free')),
               new TwoLevelListItem(title: new Text('Four'))
             ]
          ),
           new TwoLevelListItem(title: new Text('Bottom'))
        ]
      )
    );
  }
}
