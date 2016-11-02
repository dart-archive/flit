// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../diagnostics.dart';


class NavigationIconView {
  NavigationIconView({
    Icon icon,
    Widget title,
    Color color,
    TickerProvider vsync,
  }) : _icon = icon,
       _color = color,
       destinationLabel = new DestinationLabel(
         icon: icon,
         title: title,
         backgroundColor: color,
       ),
       controller = new AnimationController(
         duration: kThemeAnimationDuration,
         vsync: vsync,
       ) {
    _animation = new CurvedAnimation(
      parent: controller,
      curve: new Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
  }

  final Icon _icon;
  final Color _color;
  final DestinationLabel destinationLabel;
  final AnimationController controller;
  CurvedAnimation _animation;

  FadeTransition transition(BottomNavigationBarType type, BuildContext context) {
    Color iconColor;
    if (type == BottomNavigationBarType.shifting) {
      iconColor = _color;
    } else {
      final ThemeData themeData = Theme.of(context);
      iconColor = themeData.brightness == Brightness.light
          ? themeData.primaryColor
          : themeData.accentColor;
    }

    return new FadeTransition(
      opacity: _animation,
      child: new SlideTransition(
        position: new Tween<FractionalOffset>(
          begin: const FractionalOffset(0.0, 0.02), // Small offset from the top.
          end: FractionalOffset.topLeft,
        ).animate(_animation),
        child: new Icon(_icon.icon, color: iconColor, size: 120.0),
      ),
    );
  }
}

class BottomNavigationDemo extends StatefulWidget {
  static const String routeName = '/bottom_navigation';

  @override
  _BottomNavigationDemoState createState() => new _BottomNavigationDemoState();
}

class _BottomNavigationDemoState extends State<BottomNavigationDemo>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  BottomNavigationBarType _type = BottomNavigationBarType.shifting;
  List<NavigationIconView> _navigationViews;

  @override
  void initState() {
    super.initState();
    _navigationViews = <NavigationIconView>[
      new NavigationIconView(
        icon: new Icon(Icons.access_alarm),
        title: new Text('Alarm'),
        color: Colors.deepPurple[500],
        vsync: this,
      ),
      new NavigationIconView(
        icon: new Icon(Icons.cloud),
        title: new Text('Cloud'),
        color: Colors.teal[500],
        vsync: this,
      ),
      new NavigationIconView(
        icon: new Icon(Icons.favorite),
        title: new Text('Favorites'),
        color: Colors.indigo[500],
        vsync: this,
      ),
      new NavigationIconView(
        icon: new Icon(Icons.event_available),
        title: new Text('Event'),
        color: Colors.pink[500],
        vsync: this,
      )
    ];

    for (NavigationIconView view in _navigationViews)
      view.controller.addListener(_rebuild);

    _navigationViews[_currentIndex].controller.value = 1.0;
  }

  @override
  void dispose() {
    for (NavigationIconView view in _navigationViews)
      view.controller.dispose();
    super.dispose();
  }

  void _rebuild() {
    setState(() {
      // Rebuild in order to animate views.
    });
  }

  Widget _buildBody() {
    final List<FadeTransition> transitions = <FadeTransition>[];

    for (NavigationIconView view in _navigationViews)
      transitions.add(view.transition(_type, context));

    // We want to have the newly animating (fading in) views on top.
    transitions.sort((FadeTransition a, FadeTransition b) {
      double aValue = a.animation.value;
      double bValue = b.animation.value;
      return aValue.compareTo(bValue);
    });

    return new Stack(children: transitions);
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBar botNavBar = new BottomNavigationBar(
      labels: _navigationViews
          .map((NavigationIconView navigationView) => navigationView.destinationLabel)
          .toList(),
      currentIndex: _currentIndex,
      type: _type,
      onTap: (int index) {
        setState(() {
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
        });
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Bottom navigation'),
        actions: <Widget>[
          new PopupMenuButton<BottomNavigationBarType>(
            onSelected: (BottomNavigationBarType value) {
              setState(() {
                _type = value;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<BottomNavigationBarType>>[
              new PopupMenuItem<BottomNavigationBarType>(
                value: BottomNavigationBarType.fixed,
                child: new Text('Fixed'),
              ),
              new PopupMenuItem<BottomNavigationBarType>(
                value: BottomNavigationBarType.shifting,
                child: new Text('Shifting'),
              )
            ],
          )
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: botNavBar,
    );
  }
}
