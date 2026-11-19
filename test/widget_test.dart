import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medilink/core/di/injector.dart';
import 'package:medilink/main.dart';

void main() {
  setUp(() async {
    await sl.reset();
    configureDependencies();
  });

  testWidgets('home shows doctors and navigation', (tester) async {
    // Typical phone viewport (390 x 844 logical px) instead of the default 800 x 600.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MediLinkApp());
    await tester.pumpAndSettle();

    expect(find.text('Top doctors', skipOffstage: false), findsOneWidget);
    expect(find.text('Dr. Sarah Ahmed', skipOffstage: false), findsWidgets);
    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('Records'), findsOneWidget);
  });
}
