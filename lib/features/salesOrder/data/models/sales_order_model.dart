class SalesOrder {
  const SalesOrder({
    required this.name,
    required this.customer,
    required this.customerName,
    required this.transactionDate,
    required this.deliveryDate,
    required this.status,
    required this.grandTotal,
    required this.currency,
    required this.perDelivered,
    required this.perBilled,
    required this.deliveryProgressLabel,
  });
  final String name,
      customer,
      customerName,
      transactionDate,
      deliveryDate,
      status,
      currency,
      deliveryProgressLabel;
  final double grandTotal, perDelivered, perBilled;
  factory SalesOrder.fromJson(Map<String, dynamic> json) => SalesOrder(
    name: _text(json['name']),
    customer: _text(json['customer']),
    customerName: _text(json['customer_name']),
    transactionDate: _text(json['transaction_date']),
    deliveryDate: _text(json['delivery_date']),
    status: _text(json['status']),
    grandTotal: _number(json['grand_total']),
    currency: _text(json['currency'], fallback: 'IDR'),
    perDelivered: _percent(json['per_delivered']),
    perBilled: _percent(json['per_billed']),
    deliveryProgressLabel: _text(json['delivery_progress_label']),
  );
}

class SalesOrderPageData {
  const SalesOrderPageData({
    required this.items,
    required this.page,
    required this.hasNext,
    required this.total,
  });
  final List<SalesOrder> items;
  final int page, total;
  final bool hasNext;
}

class PendingSalesOrderItem {
  const PendingSalesOrderItem({
    required this.salesOrder,
    required this.salesOrderItem,
    required this.customer,
    required this.customerName,
    required this.itemCode,
    required this.itemName,
    required this.transactionDate,
    required this.deliveryDate,
    required this.status,
    required this.qty,
    required this.uom,
    required this.deliveredQty,
    required this.remainingQty,
    required this.pendingDeliveryQty,
    required this.isOverdue,
    required this.overdueDays,
  });
  final String salesOrder,
      salesOrderItem,
      customer,
      customerName,
      itemCode,
      itemName,
      transactionDate,
      deliveryDate,
      status,
      uom;
  final double qty, deliveredQty, remainingQty, pendingDeliveryQty;
  final bool isOverdue;
  final int overdueDays;
  factory PendingSalesOrderItem.fromJson(Map<String, dynamic> json) {
    final deliveryDate = _text(json['delivery_date']);
    final remainingQty = _number(json['remaining_qty']);
    final parsedDeliveryDate = DateTime.tryParse(deliveryDate);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final calculatedOverdue =
        remainingQty > 0 &&
        parsedDeliveryDate != null &&
        parsedDeliveryDate.isBefore(todayOnly);
    final overdueDays = calculatedOverdue
        ? todayOnly.difference(parsedDeliveryDate).inDays
        : 0;
    return PendingSalesOrderItem(
      salesOrder: _text(json['sales_order']),
      salesOrderItem: _text(json['sales_order_item'] ?? json['name']),
      customer: _text(json['customer']),
      customerName: _text(json['customer_name']),
      itemCode: _text(json['item_code']),
      itemName: _text(json['item_name']),
      transactionDate: _text(json['transaction_date']),
      deliveryDate: deliveryDate,
      status: _text(json['status']),
      qty: _number(json['qty']),
      uom: _text(json['uom']),
      deliveredQty: _number(json['delivered_qty']),
      remainingQty: remainingQty,
      pendingDeliveryQty: json.containsKey('pending_delivery_qty')
          ? _number(json['pending_delivery_qty'])
          : remainingQty,
      isOverdue: json.containsKey('is_overdue')
          ? _bool(json['is_overdue'])
          : calculatedOverdue,
      overdueDays: json.containsKey('overdue_days')
          ? _number(json['overdue_days']).toInt()
          : overdueDays,
    );
  }
}

class PendingItemsSummary {
  const PendingItemsSummary({
    this.totalSalesOrders = 0,
    this.totalItemRows = 0,
    this.overdueRows = 0,
  });
  final int totalSalesOrders, totalItemRows, overdueRows;
  factory PendingItemsSummary.fromJson(Map<String, dynamic> json) =>
      PendingItemsSummary(
        totalSalesOrders: _number(json['total_sales_orders']).toInt(),
        totalItemRows: _number(json['total_item_rows']).toInt(),
        overdueRows: _number(json['overdue_rows']).toInt(),
      );
}

class PendingItemsPageData {
  const PendingItemsPageData({
    required this.items,
    required this.page,
    required this.hasNext,
    required this.total,
    required this.summary,
  });
  final List<PendingSalesOrderItem> items;
  final int page, total;
  final bool hasNext;
  final PendingItemsSummary summary;
}

String _text(Object? value, {String fallback = '-'}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

double _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

double _percent(Object? value) => _number(value).clamp(0, 100).toDouble();
bool _bool(Object? value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';
