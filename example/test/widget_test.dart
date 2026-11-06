import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:router_pro/router_lib.dart';

import 'package:router_lifecycle_example/main.dart';

void main() {
  testWidgets('example app boots into the router home page',
      (WidgetTester tester) async {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
    addTearDown(() {
      VisibilityDetectorController.instance.updateInterval =
          const Duration(milliseconds: 500);
      VisibilityDetectorController.instance.notifyNow();
    });

    initRouter();

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MyApp), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
