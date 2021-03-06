// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'calculator/home.dart';
import '../diagnostics.dart';


class CalculatorDemo extends StatelessWidget {
  CalculatorDemo({Key key}) : super(key: key);

  static const String routeName = '/calculator';

  @override
  Widget build(BuildContext context) => new Calculator();
}
