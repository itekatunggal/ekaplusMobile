import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_detail_model.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_item_detail_model.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sales order list maps official delivery and billing progress', () {
    final order = SalesOrder.fromJson({
      'name': 'SO-001',
      'status': 'To Deliver and Bill',
      'transaction_date': '2026-10-30',
      'grand_total': 120000,
      'currency': 'IDR',
      'per_delivered': 45,
      'per_billed': 70,
      'delivery_progress_label': 'Partially Delivered',
    });
    expect(order.perDelivered, 45);
    expect(order.perBilled, 70);
    expect(order.status, 'To Deliver and Bill');
  });

  test('pending item uses backend remaining quantity and row id', () {
    final item = PendingSalesOrderItem.fromJson({
      'name': 'ROW-001',
      'sales_order': 'SO-001',
      'qty': 10,
      'delivered_qty': 3,
      'remaining_qty': 9,
      'pending_delivery_qty': 8,
      'is_overdue': 1,
      'overdue_days': 4,
    });
    expect(item.salesOrderItem, 'ROW-001');
    expect(item.remainingQty, 9);
    expect(item.pendingDeliveryQty, 8);
    expect(item.isOverdue, isTrue);
  });

  test('maps the new items-to-be-delivered response without a row id', () {
    final deliveryDate = DateTime.now().subtract(const Duration(days: 3));
    final item = PendingSalesOrderItem.fromJson({
      'sales_order': 'SO-00086',
      'customer': 'EKA TUNGGAL TIMUR MAKASAR',
      'customer_name': 'EKA TUNGGAL TIMUR MAKASAR',
      'transaction_date': '2026-05-05',
      'delivery_date': deliveryDate.toIso8601String().substring(0, 10),
      'status': 'To Deliver and Bill',
      'item_code': '0160062000008',
      'item_name': 'LIST DIAGONAL TIPIS MAROON 90 Y',
      'qty': 100,
      'delivered_qty': 0,
      'remaining_qty': 100,
      'uom': 'ROLL',
      'warehouse': 'INTERNAL WAREHOUSE',
    });

    expect(item.salesOrder, 'SO-00086');
    expect(item.customer, 'EKA TUNGGAL TIMUR MAKASAR');
    expect(item.pendingDeliveryQty, 100);
    expect(item.isOverdue, isTrue);
    expect(item.overdueDays, greaterThanOrEqualTo(3));
  });

  test('item detail handles history permissions per document type', () {
    final detail = SalesOrderItemDetail.fromJson({
      'sales_order': {'name': 'SO-001'},
      'item': {'name': 'ROW-001', 'qty': 4, 'remaining_qty': 1},
      'delivery_notes': [],
      'sales_invoices': [],
      'history_scope': {
        'delivery_notes': 'authorized_documents_only',
        'sales_invoices': 'no_read_permission',
      },
      'history_note': {'sales_invoices': 'Invoice dibatasi untuk akun ini.'},
    });
    expect(detail.deliveryHistoryRestricted, isFalse);
    expect(detail.invoiceHistoryRestricted, isTrue);
    expect(detail.invoiceHistoryNote, 'Invoice dibatasi untuk akun ini.');
  });

  test('ERP html is sanitized and line breaks are retained', () {
    expect(
      sanitizeErpText('<p>Jalan A<br>Jakarta &amp; Barat</p>'),
      'Jalan A\nJakarta & Barat',
    );
  });
}
