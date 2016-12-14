// Copyright 2016 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import "package:test_target/target_class.dart";

// We can't wrap this
const reallyConst = const ConstSubClass(0);

main() {
  print (reallyConst);
}

