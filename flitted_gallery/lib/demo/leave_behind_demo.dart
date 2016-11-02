// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:collection/collection.dart' show lowerBound;

import 'package:flutter/material.dart';

enum LeaveBehindDemoAction {
  reset,
  horizontalSwipe,
  leftSwipe,
  rightSwipe
}

class LeaveBehindItem implements Comparable<LeaveBehindItem> {
  LeaveBehindItem({ this.index, this.name, this.subject, this.body });

  LeaveBehindItem.from(LeaveBehindItem item)
    : index = item.index, name = item.name, subject = item.subject, body = item.body;

  final int index;
  final String name;
  final String subject;
  final String body;

  @override
  int compareTo(LeaveBehindItem other) => index.compareTo(other.index);
}

class LeaveBehindDemo extends StatefulWidget {
  LeaveBehindDemo({ Key key }) : super(key: key);

  static const String routeName = '/leave-behind';

  @override
  LeaveBehindDemoState createState() => new LeaveBehindDemoState();
}

class LeaveBehindDemoState extends State<LeaveBehindDemo> {
  static final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static final GlobalKey<ScrollableState> _scrollableKey = new GlobalKey<ScrollableState>();
  DismissDirection _dismissDirection = DismissDirection.horizontal;
  List<LeaveBehindItem> leaveBehindItems;

  void initListItems() {
    leaveBehindItems = new List<LeaveBehindItem>.generate(16, (int index) {
      return new LeaveBehindItem(
        index: index,
        name: 'Item $index Sender',
        subject: 'Subject: $index',
        body: "[$index] first line of the message's body..."
      );
    });
  }

  @override
  void initState() {
    super.initState();
    initListItems();
  }

  void handleDemoAction(LeaveBehindDemoAction action) {
    switch(action) {
      case LeaveBehindDemoAction.reset:
        initListItems();
        break;
      case LeaveBehindDemoAction.horizontalSwipe:
        _dismissDirection = DismissDirection.horizontal;
        break;
      case LeaveBehindDemoAction.leftSwipe:
        _dismissDirection = DismissDirection.endToStart;
        break;
      case LeaveBehindDemoAction.rightSwipe:
        _dismissDirection = DismissDirection.startToEnd;
        break;
    }
  }

  void handleUndo(LeaveBehindItem item) {
    int insertionIndex = lowerBound(leaveBehindItems, item);
    setState(() {
      leaveBehindItems.insert(insertionIndex, item);
    });
  }

  Widget buildItem(LeaveBehindItem item) {
    final ThemeData theme = Theme.of(context);
    return new Dismissable(
      key: new ObjectKey(item),
      direction: _dismissDirection,
      onDismissed: (DismissDirection direction) {
        setState(() {
          leaveBehindItems.remove(item);
        });
        final String action = (direction == DismissDirection.endToStart) ? 'archived' : 'deleted';
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text('You $action item ${item.index}'),
          action: new SnackBarAction(
            label: 'UNDO',
            onPressed: () { handleUndo(item); }
          )
        ));
      },
      background: new Container(
        decoration: new BoxDecoration(backgroundColor: theme.primaryColor),
        child: new ListItem(
          leading: new Icon(Icons.delete, color: Colors.white, size: 36.0)
        )
      ),
      secondaryBackground: new Container(
        decoration: new BoxDecoration(backgroundColor: theme.primaryColor),
        child: new ListItem(
          trailing: new Icon(Icons.archive, color: Colors.white, size: 36.0)
        )
      ),
      child: new Container(
        decoration: new BoxDecoration(
          backgroundColor: theme.canvasColor,
          border: new Border(bottom: new BorderSide(color: theme.dividerColor))
        ),
        child: new ListItem(
          title: new Text(item.name),
          subtitle: new Text('${item.subject}\n${item.body}'),
          isThreeLine: true
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      scrollableKey: _scrollableKey,
      appBar: new AppBar(
        title: new Text('Swipe to dismiss'),
        actions: <Widget>[
          new PopupMenuButton<LeaveBehindDemoAction>(
            onSelected: handleDemoAction,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<LeaveBehindDemoAction>>[
              new PopupMenuItem<LeaveBehindDemoAction>(
                value: LeaveBehindDemoAction.reset,
                child: new Text('Reset the list')
              ),
              new PopupMenuDivider(), // ignore: list_element_type_not_assignable, https://github.com/flutter/flutter/issues/5771
              new CheckedPopupMenuItem<LeaveBehindDemoAction>(
                value: LeaveBehindDemoAction.horizontalSwipe,
                checked: _dismissDirection == DismissDirection.horizontal,
                child: new Text('Hoizontal swipe')
              ),
              new CheckedPopupMenuItem<LeaveBehindDemoAction>(
                value: LeaveBehindDemoAction.leftSwipe,
                checked: _dismissDirection == DismissDirection.endToStart,
                child: new Text('Only swipe left')
              ),
              new CheckedPopupMenuItem<LeaveBehindDemoAction>(
                value: LeaveBehindDemoAction.rightSwipe,
                checked: _dismissDirection == DismissDirection.startToEnd,
                child: new Text('Only swipe right')
              )
            ]
          )
        ]
      ),
      body: new Block(
        scrollableKey: _scrollableKey,
        children: leaveBehindItems.map(buildItem).toList()
      )
    );
  }
}
