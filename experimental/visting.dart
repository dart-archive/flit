/* A sketch of the code needed to allow Observatory to access
 * the Flutter element/widget/render tree(s).
 * This stuff ultimately needs to go into
 *  the files rendering/bindings.dart and widgets/bindings.dart.
 *  What's missing now is an encoding of the actual Flutter objects
 *  collected  here into a JSONable form.
 */

import 'package:widgets/framework.dart' show Element;
import 'package:widgets/bindings.dart' show WidgetBinding;

List<Map<String, dynamic>> stack;

Element tree = WidgetBinding.instance.renderViewElement;
// the root of the element tree

push(Map<String, dynamic> e){stack.add(e);}

Map<String, dynamic> get pop{return stack.removeLast();}

Map<String, dynamic> get top{return stack.last;}

Map<String, dynamic> elementMap(Element e) {
  return {'element': e, 'children': []};
}

Map<String, dynamic> widgetMap(Element e) {
  return {'widget': e, 'children': []};
}

Map<String, dynamic> renderObjectMap(Element e) {
  return {'renderObject': e, 'children': []};
}

void elementCollector(Element e) {
  var map = elementMap(e);
  top['children]'].add(map);
  push(map);
  e.visitChildren(elementCollector);
  pop(map);
}

void widgetCollector(Element e) {
  var map = widgetMap(e);
  top['children]'].add(map);
  push(map);
  e.visitChildren(widgetCollector);
  pop(map);
}

void renderObjectCollector(Element e) {
  var map = renderObjectMap(e);
  top['children]'].add(map);
  push(map);
  e.visitChildren(renderObjectCollector);
  pop(map);
}

Future<Map<String, dynamic>> debugReturnElementTree() async {
  stack = [{children:[]}];
  tree.visitChildren(elementCollector);
  return top;
}

Future<Map<String, dynamic>> debugReturnWidgetTree() async {
  stack = [{children:[]}];
  tree.visitChildren(widgetCollector);
  return top;
}

Future<Map<String, dynamic>> debugReturnRenderObjectTree() async {
  stack = [{children:[]}];
  tree.visitChildren(renderObjectCollector);
  return top;
}

main(){
  registerServiceExtension('returnElementTree', debugReturnElementTree);
  registerServiceExtension('returnWidgetTree', debugReturnWidgetTree);
  // to be added to WidgetBinding.initServiceExtensions

  registerServiceExtension('returnRenderObjectTree', debugReturnRenderObjectTree);
  // to be added to RenderBinding.initServiceExtensions
}
