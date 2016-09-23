dynamic e(dynamic d) {
  var st = StackTrace.current;
  originMap[d] = st;
  return d;
}

Map originMap = {}; // TODO this will pin all UI elements for all of history

// h(dynamic d) {
//   print ("Highlighting: $d");
//   return d;
// }
