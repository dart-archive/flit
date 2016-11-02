// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'shrine_theme.dart';
import 'shrine_types.dart';

import '../../diagnostics.dart';


enum ShrineAction {
  sortByPrice,
  sortByProduct,
  emptyCart
}

class ShrinePage extends StatefulWidget {
  ShrinePage({
    Key key,
    this.scaffoldKey,
    this.scrollableKey,
    this.body,
    this.floatingActionButton,
    this.products,
    this.shoppingCart
  }) : super(key: key) {
    assert(body != null);
    assert(scaffoldKey != null);
  }

  final GlobalKey<ScaffoldState> scaffoldKey;
  final GlobalKey<ScrollableState> scrollableKey;
  final Widget body;
  final Widget floatingActionButton;
  final List<Product> products;
  final Map<Product, Order> shoppingCart;

  @override
  ShrinePageState createState() => new ShrinePageState();
}

/// Defines the Scaffold, AppBar, etc that the demo pages have in common.
class ShrinePageState extends State<ShrinePage> {
  int _appBarElevation = 0;

  bool _handleScrollNotification(ScrollNotification notification) {
    int elevation = notification.scrollable.scrollOffset <= 0.0 ? 0 : 1;
    if (elevation != _appBarElevation) {
      setState(() {
        _appBarElevation = elevation;
      });
    }
    return false;
  }

  void _showShoppingCart() {
    showModalBottomSheet/*<Null>*/(context: context, builder: (BuildContext context) {
      if (config.shoppingCart.isEmpty) {
        return new Padding(
          padding: const EdgeInsets.all(24.0),
          child: new Text('The shopping cart is empty')
        );
      }
      return new MaterialList(children: config.shoppingCart.values.map((Order order) {
        return new ListItem(
          title: new Text(order.product.name),
          leading: new Text('${order.quantity}'),
          subtitle: new Text(order.product.vendor.name)
        );
      }).toList());
    });
  }

  void _sortByPrice() {
    config.products.sort((Product a, Product b) => a.price.compareTo(b.price));
  }

  void _sortByProduct() {
    config.products.sort((Product a, Product b) => a.name.compareTo(b.name));
  }

  void _emptyCart() {
    config.shoppingCart.clear();
    config.scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text('Shopping cart is empty')));
  }

  @override
  Widget build(BuildContext context) {
    final ShrineTheme theme = ShrineTheme.of(context);
    return new Scaffold(
      key: config.scaffoldKey,
      scrollableKey: config.scrollableKey,
      appBar: new AppBar(
        elevation: _appBarElevation,
        backgroundColor: theme.appBarBackgroundColor,
        iconTheme: Theme.of(context).iconTheme,
        brightness: Brightness.light,
        flexibleSpace: new Container(
          decoration: new BoxDecoration(
            border: new Border(
              bottom: new BorderSide(color: theme.dividerColor)
            )
          )
        ),
        title: new Center(
          child: new Text('SHRINE', style: ShrineTheme.of(context).appBarTitleStyle)
        ),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.shopping_cart),
            tooltip: 'Shopping cart',
            onPressed: () {
              _showShoppingCart();
            }
          ),
          new PopupMenuButton<ShrineAction>(
            itemBuilder: (BuildContext context) => <PopupMenuItem<ShrineAction>>[
              new PopupMenuItem<ShrineAction>(
                value: ShrineAction.sortByPrice,
                child: new Text('Sort by price')
              ),
              new PopupMenuItem<ShrineAction>(
                value: ShrineAction.sortByProduct,
                child: new Text('Sort by product')
              ),
              new PopupMenuItem<ShrineAction>(
                value: ShrineAction.emptyCart,
                child: new Text('Empty shopping cart')
              )
            ],
            onSelected: (ShrineAction action) {
              switch (action) {
                case ShrineAction.sortByPrice:
                  setState(_sortByPrice);
                  break;
                case ShrineAction.sortByProduct:
                  setState(_sortByProduct);
                  break;
                case ShrineAction.emptyCart:
                  setState(_emptyCart);
                  break;
              }
            }
          )
        ]
      ),
      floatingActionButton: config.floatingActionButton,
      body: new NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: config.body
      )
    );
  }
}
