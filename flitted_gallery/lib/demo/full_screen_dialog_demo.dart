// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// This demo is based on
// https://material.google.com/components/dialogs.html#dialogs-full-screen-dialogs

enum DismissDialogAction {
  cancel,
  discard,
  save,
}

class DateTimeItem extends StatelessWidget {
  DateTimeItem({ Key key, DateTime dateTime, this.onChanged })
    : date = new DateTime(dateTime.year, dateTime.month, dateTime.day),
      time = new TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
      super(key: key) {
    assert(onChanged != null);
  }

  final DateTime date;
  final TimeOfDay time;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new DefaultTextStyle(
      style: theme.textTheme.subhead,
      child: new Row(
        children: <Widget>[
          new Flexible(
            child: new Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: new BoxDecoration(
                border: new Border(bottom: new BorderSide(color: theme.dividerColor))
              ),
              child: new InkWell(
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: date.subtract(const Duration(days: 30)),
                    lastDate: date.add(const Duration(days: 30))
                  )
                  .then((DateTime value) {
                    onChanged(new DateTime(value.year, value.month, value.day, time.hour, time.minute));
                  });
                },
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text(new DateFormat('EEE, MMM d yyyy').format(date)),
                    new Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ]
                )
              )
            )
          ),
          new Container(
            margin: const EdgeInsets.only(left: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: new BoxDecoration(
              border: new Border(bottom: new BorderSide(color: theme.dividerColor))
            ),
            child: new InkWell(
              onTap: () {
                showTimePicker(
                  context: context,
                  initialTime: time
                )
                .then((TimeOfDay value) {
                  onChanged(new DateTime(date.year, date.month, date.day, value.hour, value.minute));
                });
              },
              child: new Row(
                children: <Widget>[
                  new Text('$time'),
                  new Icon(Icons.arrow_drop_down, color: Colors.black54),
                ]
              )
            )
          )
        ]
      )
    );
  }
}

class FullScreenDialogDemo extends StatefulWidget {
  @override
  FullScreenDialogDemoState createState() => new FullScreenDialogDemoState();
}

class FullScreenDialogDemoState extends State<FullScreenDialogDemo> {
  DateTime _fromDateTime = new DateTime.now();
  DateTime _toDateTime = new DateTime.now();
  bool _allDayValue = false;
  bool _saveNeeded = false;

  void handleDismissButton(BuildContext context) {
    if (!_saveNeeded) {
      Navigator.pop(context, null);
      return;
    }

    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);

    showDialog(
      context: context,
      child: new AlertDialog(
        content: new Text(
          'Discard new event?',
          style: dialogTextStyle
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text('CANCEL'),
            onPressed: () { Navigator.pop(context, DismissDialogAction.cancel); }
          ),
          new FlatButton(
            child: new Text('DISCARD'),
            onPressed: () {
              Navigator.of(context)
                ..pop(DismissDialogAction.discard) // pop the cancel/discard dialog
                ..pop(); // pop this route
            }
          )
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.clear),
          onPressed: () { handleDismissButton(context); }
        ),
        title: new Text('New event'),
        actions: <Widget> [
          new FlatButton(
            child: new Text('SAVE', style: theme.textTheme.body1.copyWith(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context, DismissDialogAction.save);
            }
          )
        ]
      ),
      body: new Block(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: new BoxDecoration(
              border: new Border(bottom: new BorderSide(color: theme.dividerColor))
            ),
            alignment: FractionalOffset.bottomLeft,
            child: new Text('Event name', style: theme.textTheme.display2)
          ),
          new Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: new BoxDecoration(
              border: new Border(bottom: new BorderSide(color: theme.dividerColor))
            ),
            alignment: FractionalOffset.bottomLeft,
            child: new Text('Location', style: theme.textTheme.title.copyWith(color: Colors.black54))
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text('From', style: theme.textTheme.caption),
              new DateTimeItem(
                dateTime: _fromDateTime,
                onChanged: (DateTime value) {
                  setState(() {
                    _fromDateTime = value;
                    _saveNeeded = true;
                  });
                }
              )
            ]
          ),
          new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text('To', style: theme.textTheme.caption),
              new DateTimeItem(
                dateTime: _toDateTime,
                onChanged: (DateTime value) {
                  setState(() {
                    _toDateTime = value;
                    _saveNeeded = true;
                  });
                }
              )
            ]
          ),
          new Container(
            decoration: new BoxDecoration(
              border: new Border(bottom: new BorderSide(color: theme.dividerColor))
            ),
            child: new Row(
              children: <Widget> [
                new Checkbox(
                  value: _allDayValue,
                  onChanged: (bool value) {
                    setState(() {
                      _allDayValue = value;
                      _saveNeeded = true;
                    });
                  }
                ),
                new Text('All-day')
              ]
            )
          )
        ]
        .map((Widget child) {
          return new Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            height: 96.0,
            child: child
          );
        })
        .toList()
      )
    );
  }
}
