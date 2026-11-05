import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps only customer-facing sales order fields', () {
    final detail = SalesOrderDetail.fromJson({
      'name': 'SO-001',
      'customer': 'CUST-01',
      'customer_name': 'Customer Aman',
      'transaction_date': '2026-09-17',
      'delivery_date': '2026-09-22',
      'status': 'Completed',
      'delivery_status': 'Fully Delivered',
      'billing_status': 'Fully Billed',
      'per_delivered': 125,
      'per_billed': -10,
      'grand_total': 135000000,
      'currency': 'IDR',
      'payment_terms_template': '90 Hari',
      'opsi_pengiriman': 'Alamat Default',
      'lokasi': 'Kirim ke Kantor',
      'shipping_address_display': 'Jl. Aman 1',
      'sales': 'Internal Sales',
      'koordinator': 'Internal Coordinator',
      'catatan': 'Catatan internal',
      'company': 'Internal Company',
      'items': [
        {
          'item_code': 'ITEM-01',
          'item_name': 'Produk Customer',
          'qty': 4,
          'uom': 'KG',
          'rate': 33750,
          'amount': 135000,
          'warehouse': 'Internal Warehouse',
          'valuation_rate': 100,
        },
      ],
    });

    final map = detail.toDetailMap();

    expect(detail.perDelivered, 100);
    expect(detail.perBilled, 0);
    expect(map['shippingAddress'], 'Jl. Aman 1');
    expect(map, isNot(contains('sales')));
    expect(map, isNot(contains('koordinator')));
    expect(map, isNot(contains('catatan')));
    expect(map, isNot(contains('company')));
    expect(map['items'].first, isNot(contains('warehouse')));
    expect(map['items'].first, isNot(contains('valuationRate')));
  });

  test('does not use internal address fields as shipping fallback', () {
    final detail = SalesOrderDetail.fromJson({
      'address_display': 'Alamat internal',
      'customer_address': 'ADDR-INTERNAL',
    });

    expect(detail.shippingAddress, '-');
  });
}
