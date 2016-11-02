// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TravelDestination {
  const TravelDestination({ this.assetName, this.title, this.description });

  final String assetName;
  final String title;
  final List<String> description;

  bool get isValid => assetName != null && title != null && description?.length == 3;
}

final List<TravelDestination> destinations = <TravelDestination>[
  const TravelDestination(
    assetName: 'packages/flutter_gallery_assets/top_10_australian_beaches.jpg',
    title: 'Top 10 Australian beaches',
    description: const <String>[
      'Number 10',
      'Whitehaven Beach',
      'Whitsunday Island, Whitsunday Islands'
    ]
  ),
  const TravelDestination(
    assetName: 'packages/flutter_gallery_assets/kangaroo_valley_safari.jpg',
    title: 'Kangaroo Valley Safari',
    description: const <String>[
      '2031 Moss Vale Road',
      'Kangaroo Valley 2577',
      'New South Wales'
    ]
  )
];

class TravelDestinationItem extends StatelessWidget {
  TravelDestinationItem({ Key key, this.destination }) : super(key: key) {
    assert(destination != null && destination.isValid);
  }

  static final double height = 328.0;
  final TravelDestination destination;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextStyle titleStyle = theme.textTheme.headline.copyWith(color: Colors.white);
    TextStyle descriptionStyle = theme.textTheme.subhead;

    return new SizedBox(
      height: height,
      child: new Card(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // photo and title
            new SizedBox(
              height: 184.0,
              child: new Stack(
                children: <Widget>[
                  new Positioned.fill(
                    child: new Image.asset(
                      destination.assetName,
                      fit: ImageFit.cover
                    )
                  ),
                  new Positioned(
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                    child: new FittedBox(
                      fit: ImageFit.scaleDown,
                      alignment: FractionalOffset.centerLeft,
                      child: new Text(destination.title,
                        style: titleStyle,
                      ),
                    ),
                  ),
                ]
              )
            ),
            // description and share/expore buttons
            new Flexible(
              child: new Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                child: new DefaultTextStyle(
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: descriptionStyle,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // three line description
                      new Text(destination.description[0]),
                      new Text(destination.description[1]),
                      new Text(destination.description[2]),
                    ]
                  )
                )
              )
            ),
            // share, explore buttons
            // TODO(abarth): The theme and the bar should be part of card.
            new ButtonTheme.bar(
              child: new ButtonBar(
                alignment: MainAxisAlignment.start,
                children: <Widget>[
                  new FlatButton(
                    child: new Text('SHARE'),
                    onPressed: () { /* do nothing */ }
                  ),
                  new FlatButton(
                    child: new Text('EXPLORE'),
                    onPressed: () { /* do nothing */ }
                  ),
                ]
              )
            ),
          ]
        )
      )
    );
  }
}

class CardsDemo extends StatelessWidget {
  static final GlobalKey<ScrollableState> _scrollableKey = new GlobalKey<ScrollableState>();
  static const String routeName = '/cards';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      scrollableKey: _scrollableKey,
      appBar: new AppBar(
        title: new Text('Travel stream')
      ),
      body: new ScrollableList(
        scrollableKey: _scrollableKey,
        itemExtent: TravelDestinationItem.height,
        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
        children: destinations.map((TravelDestination destination) {
          return new Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: new TravelDestinationItem(destination: destination)
          );
        })
        .toList()
      )
    );
  }
}
