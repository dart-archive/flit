// Copyright 2015 the Dart project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'dart:html';
import 'dart:convert';

void main() {

  querySelector('#dump').onClick.listen((_) {
    HttpRequest.getString('http://localhost:9998/getIds').then((s) {
      Map elements = JSON.decode(s);

//      querySelector('#dumpResults').text = s;


      StringBuffer sb = new StringBuffer();
      sb.writeln("<table>");

      elements.forEach((k, v) {
        int id = int.parse(k);

        sb.writeln("<tr id='item$id'>");

        // e.g. {"2":{"path":"myapp.dart","line":54,"char":16,"widgetName":"Text"}}

        String path = v["path"];
        int line = v["line"];
        int char = v["char"];
        String widgetName = v["widgetName"];

        sb.writeln("<td>$path</td><td>$line:$char</td><td>$widgetName</td>");

        String rowText = "$path $line:$char $widgetName";
        print (rowText);
        sb.writeln("</tr>");
      });

      sb.writeln("</table>");

      querySelector('#hoverMap').innerHtml = sb.toString();

      for (String key in elements.keys) {
        int id = int.parse(key);

        var htmlElement = querySelector('#item$id');

        htmlElement.onMouseEnter.listen((_) {
          print ("Setting bg color on $id");
          htmlElement.style.setProperty("background-color", "#ff978f");
          sendUpdateId(id);
        });

        htmlElement.onMouseLeave.listen((_) {
          print ("Unsetting bg color on $id");
          htmlElement.style.setProperty("background-color", "#ffffff");
        });
      }
    });
  });

}


void sendUpdateId(int id) {
  HttpRequest request = new HttpRequest(); // create a new XHR

  // add an event handler that is called when the request finishes
  request.onReadyStateChange.listen((_) {
    if (request.readyState == HttpRequest.DONE &&
        (request.status == 200 || request.status == 0)) {
      // data saved OK.
      print(request.responseText); // output the response from the server
    }
  });

  // POST the data to the server
  var url = "http://127.0.0.1:9998/setHighlights";
  request.open("POST", url, async: false);

  String jsonData = JSON.encode([id]);
  request.send(jsonData); // perform the async POST
}