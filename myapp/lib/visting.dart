/* A sketch of the code needed to allow Observatory to access
 * the Flutter element/widget/render tree(s).
 * This stuff ultimately needs to go into
 *  the files rendering/bindings.dart and widgets/bindings.dart.
 *
 *  It may be possible to use the VM's facilities to provide "stable-ish"
 *  object ids that can be serialized, which could then be used to
 *  manipulate the objects or retrieve more information. This would
 *  require additional VM support.
 */

import 'dart:async' show Future;

import 'package:flutter/widgets.dart' as flutter
    show Element, RenderObjectElement;

import 'package:flutter/src/rendering/binding.dart' as flutterWidgetBindings
    show RendererBinding;
import 'package:flutter/src/widgets/binding.dart' as flutterWidgetBindings
    show WidgetsBinding;


List<Map<String, dynamic>> stack;

flutter.Element tree =
    flutterWidgetBindings.WidgetsBinding.instance.renderViewElement;
// the root of the element tree

push(Map<String, dynamic> e) {
  stack.add(e);
}

Map<String, dynamic> pop() {
  return stack.removeLast();
}

Map<String, dynamic> top() {
  return stack.last;
}

String mapType(Type t) => t.toString();

Map<String, dynamic> mapWidget(e) {
  return {'type': mapType(e.runtimeType)};
}

Map<String, dynamic> mapRenderObject(e) {
  return {'type': mapType(e.runtimeType)};
}

Map<String, dynamic> mapElement(e) {
  return {
    'type': mapType(e.runtimeType),
    'widget': mapWidget(e.widget),
    'isRenderElement': e is flutter.RenderObjectElement,
    'renderObject': mapRenderObject(e.renderObject)
  };
}

Map<String, dynamic> elementMap(flutter.Element e) {
  return {'element': mapElement(e), 'children': []};
}

void elementCollector(flutter.Element e) {
  var map = elementMap(e);
  top()['children'].add(map);
  push(map);
  e.visitChildren(elementCollector);
  pop();
}

// for next 3 functions - what is the formal
// parameter for

/* Allow Observatory to access
 * the Flutter element tree.
 *  The actual Flutter objects
 *  collected  are serialized into maps
 *  to whatever depth we find useful.  Observatory has expectations wrt to
 *  this - it expects a type field for example.
 */
Future<Map<String, dynamic>> debugReturnElementTree(
    Map<String, String> parameters) async {
  List<Map<String, dynamic>> stack = [
    {'children': []}
  ];

  flutter.Element tree =
      flutterWidgetBindings.WidgetsBinding.instance.renderViewElement;
// the root of the element tree

  push(Map<String, dynamic> e) {
    stack.add(e);
  }

  Map<String, dynamic> pop() {
    return stack.removeLast();
  }

  Map<String, dynamic> top() {
    return stack.last;
  }

  String mapType(Type t) => t.toString();

  Map<String, dynamic> mapWidget(e) {
    return {'type': mapType(e.runtimeType)};
  }

  Map<String, dynamic> mapRenderObject(e) {
    return {'type': mapType(e.runtimeType)};
  }

  Map<String, dynamic> mapElement(e) {
    return {
      'type': mapType(e.runtimeType),
      'widget': mapWidget(e.widget),
      'isRenderElement': e is flutter.RenderObjectElement,
      'renderObject': mapRenderObject(e.renderObject)
    };
  }

  Map<String, dynamic> elementMap(flutter.Element e) {
    return {'element': mapElement(e), 'children': []};
  }

  void elementCollector(flutter.Element e) {
    var map = elementMap(e);
    top()['children'].add(map);
    push(map);
    e.visitChildren(elementCollector);
    pop();
  }

  tree.visitChildren(elementCollector);
  return top();
}

/* Allow Observatory to access
 * the Flutter widget tree.
 *  The actual Flutter objects
 *  collected  are serialized into maps
 *  to whatever depth we find useful.
 */
Future<Map<String, dynamic>> debugReturnWidgetTree(
    Map<String, String> parameters) async {
  List<Map<String, dynamic>> stack = [
    {'children': []}
  ];

  flutter.Element tree =
      flutterWidgetBindings.WidgetsBinding.instance.renderViewElement;
// the root of the element tree

  push(Map<String, dynamic> e) {
    stack.add(e);
  }

  Map<String, dynamic> pop() {
    return stack.removeLast();
  }

  Map<String, dynamic> top() {
    return stack.last;
  }

  String mapType(Type t) => t.toString();

  Map<String, dynamic> mapWidget(e) {
    return {'type': mapType(e.runtimeType)};
  }

  Map<String, dynamic> widgetMap(flutter.Element e) {
    return {'widget': mapWidget(e), 'children': []};
  }

  void widgetCollector(flutter.Element e) {
    var map = widgetMap(e);
    top()['children]'].add(map);
    push(map);
    e.visitChildren(widgetCollector);
    pop();
  }

  tree.visitChildren(widgetCollector);
  return top();
}

/* Allow Observatory to access
 * the Flutter render tree.
 *  The actual Flutter objects
 *  collected  are serialized into maps
 *  to whatever depth we find useful.
 */
Future<Map<String, dynamic>> debugReturnRenderObjectTree(
    Map<String, String> parameters) async {
  List<Map<String, dynamic>> stack = [
    {'children': []}
  ];

  flutter.Element tree =
      flutterWidgetBindings.WidgetsBinding.instance.renderViewElement;
// the root of the element tree

  push(Map<String, dynamic> e) {
    stack.add(e);
  }

  Map<String, dynamic> pop() {
    return stack.removeLast();
  }

  Map<String, dynamic> top() {
    return stack.last;
  }

  String mapType(Type t) => t.toString();

  Map<String, dynamic> mapRenderObject(e) {
    return {'type': mapType(e.runtimeType)};
  }

  Map<String, dynamic> renderObjectMap(flutter.Element e) {
    return {'renderObject': mapRenderObject(e), 'children': []};
  }

  void renderObjectCollector(flutter.Element e) {
    var map = renderObjectMap(e);
    top()['children]'].add(map);
    push(map);
    e.visitChildren(renderObjectCollector);
    pop();
  }

  tree.visitChildren(renderObjectCollector);
  return top();
}

main() {
/*  flutterWidgetBindings.WidgetsBinding.instance.registerServiceExtension(
      name: 'returnElementTree', callback: debugReturnElementTree);
  flutterWidgetBindings.WidgetsBinding.instance.registerServiceExtension(
      name: 'returnWidgetTree', callback: debugReturnWidgetTree);
  // to be added to WidgetBinding.initServiceExtensions

  flutterWidgetBindings.RendererBinding.instance.registerServiceExtension(
      name: 'returnRenderObjectTree', callback: debugReturnRenderObjectTree);
  // to be added to RenderBinding.initServiceExtensions
*/}
