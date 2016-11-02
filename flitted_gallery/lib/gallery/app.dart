// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;


import 'item.dart';
import 'home.dart';
import 'updates.dart';
import '../diagnostics.dart';

final Map<String, WidgetBuilder> _kRoutes = new Map<String, WidgetBuilder>.fromIterable(
  kAllGalleryItems,
  key: (GalleryItem item) => item.routeName,
  value: (GalleryItem item) => item.buildRoute,
);

final ThemeData _kGalleryLightTheme = new ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.lightBlue,
);

final ThemeData _kGalleryDarkTheme = new ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.lightBlue,
);

class GalleryApp extends StatefulWidget {
  GalleryApp({
    this.updateUrlFetcher,
    this.enablePerformanceOverlay: true,
    Key key}
  ) : super(key: key);

  final UpdateUrlFetcher updateUrlFetcher;
  final bool enablePerformanceOverlay;

  @override
  GalleryAppState createState() {
    return globalState = new GalleryAppState();
  }
}

class GalleryAppState extends State<GalleryApp> {
  bool _useLightTheme = true;
  bool _showPerformanceOverlay = false;

  TargetPlatform platform = defaultTargetPlatform;

  @override
  Widget build(BuildContext context) {
    Widget home = h(0, new GalleryHome(
      useLightTheme: _useLightTheme,
      onThemeChanged: (bool value) {
        setState(() {
          _useLightTheme = value;
        });
      },
      showPerformanceOverlay: _showPerformanceOverlay,
      onShowPerformanceOverlayChanged: config.enablePerformanceOverlay ? (bool value) {
        setState(() {
          _showPerformanceOverlay = value;
        });
      } : null,
      onPlatformChanged: (TargetPlatform value) {
        setState(() {
          platform = value;
        });
      },
      timeDilation: timeDilation,
      onTimeDilationChanged: (double value) {
        setState(() {
          timeDilation = value;
        });
      },
    ));

    if (config.updateUrlFetcher != null) {
      home = new Updater(
        updateUrlFetcher: config.updateUrlFetcher,
        child: home,
      );
    }

    return h(1, new MaterialApp(
      title: 'Flutter Gallery',
      color: Colors.grey[500],
      theme: (_useLightTheme ? _kGalleryLightTheme : _kGalleryDarkTheme).copyWith(platform: platform),
      showPerformanceOverlay: _showPerformanceOverlay,
      routes: _kRoutes,
      home: home,
    ));
  }
}
