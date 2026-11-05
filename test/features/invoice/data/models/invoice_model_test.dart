import 'package:ekaplus_ekatunggal/features/invoice/data/models/invoice_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps per-status totals and invoice previews', () {
    final summary = InvoiceStatusSummary.fromJson('Overdue', {
      'total_count': 1,
      'total_outstanding': 23750000.0,
      'preview': [
        {
          'name': 'SJ-2026-06-0236',
          'posting_date': '2026-06-12',
          'customer': 'ALSHINDO FOAM HI',
          'customer_name': 'ALSHINDO FOAM HI',
          'due_date': '2026-07-12',
          'grand_total': 168750000.0,
          'outstanding_amount': 23750000.0,
          'status': 'Overdue',
        },
      ],
    });

    expect(summary.status, 'Overdue');
    expect(summary.totalCount, 1);
    expect(summary.totalOutstanding, 23750000);
    expect(summary.preview, hasLength(1));
    expect(summary.preview.single.name, 'SJ-2026-06-0236');
    expect(summary.preview.single.status, 'Overdue');
    expect(summary.preview.single.outstandingAmount, 23750000);
  });
}
