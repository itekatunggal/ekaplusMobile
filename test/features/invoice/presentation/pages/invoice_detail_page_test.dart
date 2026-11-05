import 'package:ekaplus_ekatunggal/features/invoice/presentation/pages/invoice_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('detail header does not overflow with a tall status bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            padding: EdgeInsets.only(top: 40),
            textScaler: TextScaler.linear(1.3),
          ),
          child: InvoiceDetailPage(
            invoice: {
              'name': 'SJ-2026-07-ET-0085',
              'series': 'SJ-2026-07-ET-0085',
              'date': '2026-07-06',
              'customer': 'ANUGERAH KARYA ASLINDO PT',
              'dueDate': '2026-10-04',
              'status': 'Paid',
              'nilai': 5500000,
              'taxTotal': 0,
              'address': <String, dynamic>{},
              'discount': <String, dynamic>{},
              'items': <Map<String, dynamic>>[],
              'taxes': <Map<String, dynamic>>[],
              'payments': <Map<String, dynamic>>[],
              'delivery': <Map<String, dynamic>>[],
              'sales': <Map<String, dynamic>>[],
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Detail Sales Invoice'), findsOneWidget);
    expect(find.text('SJ-2026-07-ET-0085'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
