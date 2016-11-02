// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef Future<String> UpdateUrlFetcher();

class Updater extends StatefulWidget {
  Updater({ this.updateUrlFetcher, this.child, Key key }) : super(key: key) {
    assert(updateUrlFetcher != null);
  }

  final UpdateUrlFetcher updateUrlFetcher;
  final Widget child;

  @override
  State createState() => new UpdaterState();
}

class UpdaterState extends State<Updater> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  static DateTime _lastUpdateCheck;
  Future<Null> _checkForUpdates() async {
    // Only prompt once a day
    if (_lastUpdateCheck != null &&
        new DateTime.now().difference(_lastUpdateCheck) < new Duration(days: 1)) {
      return; // We already checked for updates recently
    }
    _lastUpdateCheck = new DateTime.now();

    String updateUrl = await config.updateUrlFetcher();
    if (updateUrl != null) {
      bool wantsUpdate = await showDialog(context: context, child: _buildDialog());
      if (wantsUpdate != null && wantsUpdate)
        UrlLauncher.launch(updateUrl);
    }
  }

  Widget _buildDialog() {
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);
    return new AlertDialog(
      title: new Text('Update Flutter Gallery?'),
      content: new Text('A newer version is available.', style: dialogTextStyle),
      actions: <Widget>[
        new FlatButton(
            child: new Text('NO THANKS'),
            onPressed: () {
              Navigator.pop(context, false);
            }),
        new FlatButton(
            child: new Text('UPDATE'),
            onPressed: () {
              Navigator.pop(context, true);
            }),
      ]);
  }

  @override
  Widget build(BuildContext context) => config.child;
}
