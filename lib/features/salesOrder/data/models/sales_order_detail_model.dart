class SalesOrderDetailItem {
  const SalesOrderDetailItem({
    required this.rowId,
    required this.itemCode,
    required this.itemName,
    required this.description,
    required this.qty,
    required this.uom,
    required this.deliveryDate,
    required this.deliveredQty,
    required this.remainingQty,
    required this.pendingDeliveryQty,
    required this.overDeliveredQty,
    required this.isOverdue,
    required this.overdueDays,
    required this.rate,
    required this.amount,
    required this.image,
  });
  final String rowId, itemCode, itemName, description, uom, deliveryDate, image;
  final double qty,
      deliveredQty,
      remainingQty,
      pendingDeliveryQty,
      overDeliveredQty,
      rate,
      amount;
  final bool isOverdue;
  final int overdueDays;
  factory SalesOrderDetailItem.fromJson(Map<String, dynamic> json) =>
      SalesOrderDetailItem(
        rowId: _text(json['name']),
        itemCode: _text(json['item_code']),
        itemName: _text(json['item_name']),
        description: sanitizeErpText(json['description']),
        qty: _number(json['qty']),
        uom: _text(json['uom']),
        deliveryDate: _text(json['delivery_date']),
        deliveredQty: _number(json['delivered_qty']),
        remainingQty: _number(json['remaining_qty']),
        pendingDeliveryQty: _number(json['pending_delivery_qty']),
        overDeliveredQty: _number(json['over_delivered_qty']),
        isOverdue: _bool(json['is_overdue']),
        overdueDays: _number(json['overdue_days']).toInt(),
        rate: _number(json['rate']),
        amount: _number(json['amount']),
        image: _text(json['image'] ?? json['item_image']),
      );
  Map<String, dynamic> toMap() => {
    'rowId': rowId,
    'itemCode': itemCode,
    'itemName': itemName,
    'description': description,
    'qty': qty,
    'uom': uom,
    'date': deliveryDate,
    'deliveredQty': deliveredQty,
    'remainingQty': remainingQty,
    'pendingDeliveryQty': pendingDeliveryQty,
    'overDeliveredQty': overDeliveredQty,
    'isOverdue': isOverdue,
    'overdueDays': overdueDays,
    'rate': rate,
    'amount': amount,
    'image': image,
  };
}

class SalesOrderItemSummary {
  const SalesOrderItemSummary({
    this.totalRows = 0,
    this.pendingRows = 0,
    this.remainingRows = 0,
    this.overdueRows = 0,
  });
  final int totalRows, pendingRows, remainingRows, overdueRows;
  factory SalesOrderItemSummary.fromJson(Map<String, dynamic> json) =>
      SalesOrderItemSummary(
        totalRows: _number(json['total_rows']).toInt(),
        pendingRows: _number(json['pending_rows']).toInt(),
        remainingRows: _number(json['remaining_rows']).toInt(),
        overdueRows: _number(json['overdue_rows']).toInt(),
      );
  Map<String, dynamic> toMap() => {
    'totalRows': totalRows,
    'pendingRows': pendingRows,
    'remainingRows': remainingRows,
    'overdueRows': overdueRows,
  };
}

class SalesOrderDetail {
  const SalesOrderDetail({
    required this.name,
    required this.customer,
    required this.customerName,
    required this.transactionDate,
    required this.deliveryDate,
    required this.status,
    required this.deliveryStatus,
    required this.billingStatus,
    required this.perDelivered,
    required this.perBilled,
    required this.grandTotal,
    required this.currency,
    required this.customerPoNo,
    required this.customerPoDate,
    required this.paymentTermsTemplate,
    required this.shippingAddress,
    required this.items,
    required this.itemSummary,
  });
  final String name,
      customer,
      customerName,
      transactionDate,
      deliveryDate,
      status,
      deliveryStatus,
      billingStatus,
      currency,
      customerPoNo,
      customerPoDate,
      paymentTermsTemplate,
      shippingAddress;
  final double perDelivered, perBilled, grandTotal;
  final List<SalesOrderDetailItem> items;
  final SalesOrderItemSummary itemSummary;
  factory SalesOrderDetail.fromJson(Map<String, dynamic> json) {
    final rows = (json['items'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (row) =>
              SalesOrderDetailItem.fromJson(Map<String, dynamic>.from(row)),
        )
        .toList(growable: false);
    return SalesOrderDetail(
      name: _text(json['name']),
      customer: _text(json['customer']),
      customerName: _text(json['customer_name']),
      transactionDate: _text(json['transaction_date']),
      deliveryDate: _text(json['delivery_date']),
      status: _text(json['status']),
      deliveryStatus: _text(json['delivery_status']),
      billingStatus: _text(json['billing_status']),
      perDelivered: _number(json['per_delivered']).clamp(0, 100).toDouble(),
      perBilled: _number(json['per_billed']).clamp(0, 100).toDouble(),
      grandTotal: _number(json['grand_total']),
      currency: _text(json['currency'], fallback: 'IDR'),
      customerPoNo: _text(json['po_no'] ?? json['customer_po_no']),
      customerPoDate: _text(json['po_date'] ?? json['customer_po_date']),
      paymentTermsTemplate: _text(json['payment_terms_template']),
      shippingAddress: sanitizeErpText(
        json['shipping_address_display'] ?? json['shipping_address'],
      ),
      items: rows,
      itemSummary: SalesOrderItemSummary.fromJson(_map(json['item_summary'])),
    );
  }
  Map<String, dynamic> toDetailMap() => {
    'name': name,
    'customer': customer,
    'customerName': customerName,
    'transactionDate': transactionDate,
    'deliveryDate': deliveryDate,
    'status': status,
    'deliveryStatus': deliveryStatus,
    'billingStatus': billingStatus,
    'perDelivered': perDelivered,
    'perBilled': perBilled,
    'grandTotal': grandTotal,
    'currency': currency,
    'customerPoNo': customerPoNo,
    'customerPoDate': customerPoDate,
    'paymentTermsTemplate': paymentTermsTemplate,
    'shippingAddress': shippingAddress,
    'items': items.map((e) => e.toMap()).toList(growable: false),
    'itemSummary': itemSummary.toMap(),
  };
}

String sanitizeErpText(Object? value) {
  final input = value?.toString() ?? '';
  if (input.trim().isEmpty) return '-';
  return input
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .trim();
}

String _text(Object? value, {String fallback = '-'}) {
  final result = value?.toString().trim() ?? '';
  return result.isEmpty ? fallback : result;
}

double _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _bool(Object? value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';
Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
