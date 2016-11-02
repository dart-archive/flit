// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gallery/gallery/app.dart';

Future<String> mockUpdateUrlFetcher() {
  // A real implementation would connect to the network to retrieve this value
  return new Future<String>.value('http://www.example.com/');
}

void main() {
  TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is LiveTestWidgetsFlutterBinding) binding.allowAllFrames = true;

  // Regression test for https://github.com/flutter/flutter/pull/5168
  testWidgets('update dialog', (WidgetTester tester) async {
    await tester.pumpWidget(new GalleryApp(updateUrlFetcher: mockUpdateUrlFetcher));
    await tester.pump(); // see https://github.com/flutter/flutter/issues/1865
    await tester.pump(); // triggers a frame

    expect(find.text('UPDATE'), findsOneWidget);

    await tester.tap(find.text('NO THANKS'));
    await tester.pump();

    await tester.tap(find.text('Shrine'));
    await tester.pump(); // Launch shrine
    await tester.pump(const Duration(seconds: 1)); // transition is complete

    Finder backButton = find.byTooltip('Back');
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pump(); // Start the pop "back" operation.
    await tester.pump(const Duration(seconds: 1)); // transition is complete

    expect(find.text('UPDATE'), findsNothing);
  });
}
