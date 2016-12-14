// Copyright 2016 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.


@Traced()
abstract class BaseClass {
  int theAnswer = 42;

}

class SubClass extends BaseClass {
  int anotherAnswer = 1010;

}

class ClassWithCtor extends SubClass {
  String aMessage;
  ClassWithCtor({this.aMessage});
  printMe() {
    print (aMessage);
  }
}

@Traced()
abstract class ConstBaseClass {
  final int theAnswer;
  const ConstBaseClass(this.theAnswer);
}

class ConstSubClass extends ConstBaseClass {
  final int anotherAnswer;
  const ConstSubClass(this.anotherAnswer) : super(42);
}

class Traced {
  const Traced();
}

