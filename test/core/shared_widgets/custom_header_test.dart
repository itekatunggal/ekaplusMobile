import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('content is painted above and overlaps the brand header', (
    tester,
  ) async {
    const contentKey = Key('header-content');

    await tester.pumpWidget(
      const MaterialApp(
        home: CustomHeaderScaffold(
          title: 'Akun Saya',
          showBackButton: false,
          body: ColoredBox(key: contentKey, color: Colors.white),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final headerRect = tester.getRect(find.byType(CustomHeaderAppBar));
    final contentRect = tester.getRect(find.byKey(contentKey));
    final contentSize = tester.getSize(find.byKey(contentKey));

    expect(headerRect.height, 154);
    expect(contentRect.top, 116);
    expect(contentRect.top, lessThan(headerRect.bottom));
    expect(headerRect.bottom - contentRect.top, 38);
    expect(contentSize.height, greaterThan(400));
    expect(tester.takeException(), isNull);
  });
}
