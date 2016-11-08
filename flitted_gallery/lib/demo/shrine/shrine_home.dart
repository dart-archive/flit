// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'shrine_data.dart';
import 'shrine_order.dart';
import 'shrine_page.dart';
import 'shrine_theme.dart';
import 'shrine_types.dart';

import 'package:flutter_gallery/diagnostics/diagnostics.dart';


const double unitSize = kToolbarHeight;

final List<Product> _products = new List<Product>.from(allProducts());
final Map<Product, Order> _shoppingCart = <Product, Order>{};

// The Shrine home page arranges the product cards into two columns. The card
// on every 4th and 5th row spans two columns.
class ShrineGridDelegate extends GridDelegate {
  int _rowAtIndex(int index) {
    final int n = index ~/ 8;
    return const <int>[0, 0, 1, 1, 2, 2, 3, 4][index - n * 8] + n * 5;
  }

  int _columnAtIndex(int index) {
    return const <int>[0, 1, 0, 1, 0, 1, 0, 0][index % 8];
  }

  int _columnSpanAtIndex(int index) {
    return const <int>[1, 1, 1, 1, 1, 1, 2, 2][index % 8];
  }

  @override
  GridSpecification getGridSpecification(BoxConstraints constraints, int childCount) {
    assert(childCount >= 0);
    return new GridSpecification.fromRegularTiles(
      tileWidth: constraints.maxWidth / 2.0 - 8.0,
      // height = ProductPriceItem + product image + VendorItem
      tileHeight: 40.0 + 144.0 + 40.0,
      columnCount: 2,
      rowCount: childCount == 0 ? 0 : _rowAtIndex(childCount - 1) + 1,
      rowSpacing: 8.0,
      columnSpacing: 8.0
    );
  }

  @override
  GridChildPlacement getChildPlacement(GridSpecification specification, int index, Object placementData) {
    assert(index >= 0);
    return new GridChildPlacement(
      column: _columnAtIndex(index),
      row: _rowAtIndex(index),
      columnSpan: _columnSpanAtIndex(index),
      rowSpan: 1
    );
  }
}

/// Displays the Vendor's name and avatar.
class VendorItem extends StatelessWidget {
  VendorItem({ Key key, this.vendor }) : super(key: key) {
    assert(vendor != null);
  }

  final Vendor vendor;

  @override
  Widget build(BuildContext context) {
    return h(10000, new SizedBox(
        ctorLocation: "shine_home.dart:77",
        height: 24.0,
      child: h(10001, new Row(
          ctorLocation: "shine_home.dart:78",
        children: <Widget>[
          new SizedBox(
              ctorLocation: "shine_home.dart:82",
              width: 24.0,
            child: h(10002, new ClipRRect(
                ctorLocation: "shine_home.dart:84",
                borderRadius: new BorderRadius.circular(12.0),
              child: h(10003, new Image.asset(vendor.avatarAsset, fit: ImageFit.cover))
            ))
          ),
          h(10004, new SizedBox(
              ctorLocation: "shine_home.dart:90",
              width: 8.0)),
          h(10005, new Flexible(
              ctorLocation: "shine_home.dart:93",
            child: h(10006, new Text(
                vendor.name,
                style: ShrineTheme.of(context).vendorItemStyle,
            ctorLocation: "shine_home.dart:95",))
          ))
        ]
      ))
    ));
  }
}

/// Displays the product's price. If the product is in the shopping cart the background
/// is highlighted.
abstract class PriceItem extends StatelessWidget {
  PriceItem({ Key key, this.product }) : super(key: key) {
    assert(product != null);
  }

  final Product product;

  Widget buildItem(BuildContext context, TextStyle style, EdgeInsets padding) {
    BoxDecoration decoration;
    if (_shoppingCart[product] != null)
      decoration = new BoxDecoration(backgroundColor: ShrineTheme.of(context).priceHighlightColor);

    return h(10007, new Container(
      padding: padding,
      decoration: decoration,
      child: h(10008, new Text(product.priceString, style: style))
    ));
  }
}

class ProductPriceItem extends PriceItem {
  ProductPriceItem({ Key key, Product product }) : super(key: key, product: product);

  @override
  Widget build(BuildContext context) {
    return buildItem(
      context,
      ShrineTheme.of(context).priceStyle,
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
    );
  }
}

class FeaturePriceItem extends PriceItem {
  FeaturePriceItem({ Key key, Product product }) : super(key: key, product: product);

  @override
  Widget build(BuildContext context) {
    return buildItem(
      context,
      ShrineTheme.of(context).featurePriceStyle,
      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0)
    );
  }
}

/// Layout the main left and right elements of a FeatureItem.
class FeatureLayout extends MultiChildLayoutDelegate {
  FeatureLayout();

  static final String left = 'left';
  static final String right = 'right';

  // Horizontally: the feature product image appears on the left and
  // occupies 50% of the available width; the feature product's
  // description apepars on the right and occupies 50% of the available
  // width + unitSize. The left and right widgets overlap and the right
  // widget is stacked on top.
  @override
  void performLayout(Size size) {
    final double halfWidth = size.width / 2.0;
    layoutChild(left, new BoxConstraints.tightFor(width: halfWidth, height: size.height));
    positionChild(left, Offset.zero);
    layoutChild(right, new BoxConstraints.expand(width: halfWidth + unitSize, height: size.height));
    positionChild(right, new Offset(halfWidth - unitSize, 0.0));
  }

  @override
  bool shouldRelayout(FeatureLayout oldDelegate) => false;
}

/// A card that highlights the "featured" catalog item.
class FeatureItem extends StatelessWidget {
  FeatureItem({ Key key, this.product }) : super(key: key) {
    assert(product.featureTitle != null);
    assert(product.featureDescription != null);
  }

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ShrineTheme theme = ShrineTheme.of(context);
    return h(10009, new AspectRatio(
      aspectRatio: 3.0 / 3.5,
      child: h(10010, new Container(
        decoration: new BoxDecoration(
          backgroundColor: theme.cardBackgroundColor,
          border: new Border(bottom: new BorderSide(color: theme.dividerColor))
        ),
        child: h(10011, new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            h(10012, new SizedBox(
              height: unitSize,
              child: h(10013, new Align(
                alignment: FractionalOffset.topRight,
                child: new FeaturePriceItem(product: product)
              ))
            )),
            h(10014, new Flexible(
              child: h(10015, new CustomMultiChildLayout(
                delegate: new FeatureLayout(),
                children: <Widget>[
                  h(10016, new LayoutId(
                    id: FeatureLayout.left,
                    child: h(10017, new ClipRect(
                      child: h(10018, new OverflowBox(
                        minWidth: 340.0,
                        maxWidth: 340.0,
                        minHeight: 340.0,
                        maxHeight: 340.0,
                        alignment: FractionalOffset.topRight,
                        child: h(10019, new Image.asset(product.imageAsset, fit: ImageFit.cover))
                      ))
                    ))
                  )),
                  h(10019, new LayoutId(
                    id: FeatureLayout.right,
                    child: h(10020, new Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: h(10020, new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                      h(10022, new Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: h(10023, new Text(product.featureTitle, style: theme.featureTitleStyle))
                          )),
                          h(10024, new Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: h(10025, new Text(product.featureDescription, style: theme.featureStyle))
                          )),
                          new VendorItem(vendor: product.vendor)
                        ]
                      ))
                    ))
                  ))
                ]
              ))
            ))
          ]
        ))
      ))
    ));
  }
}

/// A card that displays a product's image, price, and vendor.
class ProductItem extends StatelessWidget {
  ProductItem({ Key key, this.product, this.onPressed, sourceLocation}) :
        super(key: key, ctorLocation: sourceLocation) {
    assert(product != null);
  }

  final Product product;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return h(10026, new Card(
      child: h(10027, new Stack(
        children: <Widget>[
          h(10028, new Column(
            children: <Widget>[
              h(10029, new Align(
                alignment: FractionalOffset.centerRight,
                child: h(10030, new ProductPriceItem(product: product))
              )),
              h(10031, new Container(
                width: 144.0,
                height: 144.0,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: h(10032, new Hero(
                    tag: product.tag,
                    child: h(10033, new Image.asset(product.imageAsset, fit: ImageFit.contain))
                  ))
                )),
              h(10033, new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: h(10034, new VendorItem(vendor: product.vendor))
              ))
            ]
          )),
          h(10035, new Material(
            type: MaterialType.transparency,
            child: h(10036, new InkWell(onTap: onPressed))
          )),
        ]
      ))
    ));
  }
}

/// The Shrine app's home page. Displays the featured item above all of the
/// product items arranged in two columns.
class ShrineHome extends StatefulWidget {
  @override
  _ShrineHomeState createState() => new _ShrineHomeState();
}

class _ShrineHomeState extends State<ShrineHome> {
  static final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>(debugLabel: 'Shrine Home');
  static final GlobalKey<ScrollableState> scrollableKey = new GlobalKey<ScrollableState>();
  static final GridDelegate gridDelegate = new ShrineGridDelegate();

  Future<Null> showOrderPage(Product product) async {
    final Order order = _shoppingCart[product] ?? new Order(product: product);
    final Order completedOrder = await Navigator.push(context, new ShrineOrderRoute(
      order: order,
      builder: (BuildContext context) {
        return h(10037, new OrderPage(
          order: order,
          products: _products,
          shoppingCart: _shoppingCart
        ));
      }
    ));
    assert(completedOrder.product != null);
    if (completedOrder.quantity == 0)
      _shoppingCart.remove(completedOrder.product);
  }

  @override
  Widget build(BuildContext context) {
    final Product featured = _products.firstWhere((Product product) => product.featureDescription != null);
    return h(10038, new ShrinePage(
      scaffoldKey: scaffoldKey,
      scrollableKey: scrollableKey,
      products: _products,
      shoppingCart: _shoppingCart,
      body: h(10039, new ScrollableViewport(
        scrollableKey: scrollableKey,
        child: h(10040, new RepaintBoundary(
          child: h(10041, new Column(
            children: <Widget>[
              h(10042, new FeatureItem(product: featured)),
              h(10043, new Padding(
                padding: const EdgeInsets.all(16.0),
                child: h(10044, new CustomGrid(
                  delegate: gridDelegate,
                  children: _products.map((Product product) {
                    return h(10045, new RepaintBoundary(
                      child: h(10046, new ProductItem(
                        product: product,
                        onPressed: () { showOrderPage(product); }
                      ))
                    ));
                  }).toList()
                ))
              ))
            ]
          ))
        ))
      ))
    ));
  }
}
