import 'package:ekaplus_ekatunggal/core/shared_widgets/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hides product navigation while its feature flags are off', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavBar(currentIndex: 0, onTap: (_) {}),
        ),
      ),
    );

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Cabang'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);
    expect(find.text('Kategori'), findsNothing);
    expect(find.text('Wishlist'), findsNothing);
  });

  testWidgets('remains usable at 320dp with enlarged system text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(1.6),
        ),
        child: MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavBar(currentIndex: 0, onTap: (_) {}),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel('Beranda'), findsOneWidget);
    expect(find.bySemanticsLabel('Akun'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('guest melihat empat tab tanpa Customer', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavBar(
            currentIndex: 0,
            showCustomer: false,
            onTap: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Cabang'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
    expect(find.text('Akun'), findsOneWidget);
    expect(find.text('Customer'), findsNothing);
  });
}
