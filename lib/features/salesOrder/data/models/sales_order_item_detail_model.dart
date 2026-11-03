import 'sales_order_detail_model.dart';

class SalesOrderItemHistory {
  const SalesOrderItemHistory({
    required this.document,
    required this.postingDate,
    required this.status,
    required this.qty,
    required this.uom,
    required this.amount,
    required this.currency,
    required this.isReturn,
    required this.updateStock,
  });
  final String document, postingDate, status, uom, currency;
  final double qty, amount;
  final bool isReturn, updateStock;
  factory SalesOrderItemHistory.fromJson(Map<String, dynamic> json) {
    final item = json['item'] is Map
        ? Map<String, dynamic>.from(json['item'])
        : <String, dynamic>{};
    return SalesOrderItemHistory(
      document: _text(json['document'] ?? json['name']),
      postingDate: _text(json['posting_date']),
      status: _text(json['status']),
      qty: _number(item['qty']),
      uom: _text(item['uom']),
      amount: _number(item['amount']),
      currency: _text(json['currency']),
      isReturn: _bool(json['is_return']),
      updateStock: _bool(json['update_stock']),
    );
  }
}

class SalesOrderItemDetail {
  const SalesOrderItemDetail({
    required this.salesOrder,
    required this.item,
    required this.deliveryNotes,
    required this.salesInvoices,
    required this.deliveryHistoryScope,
    required this.invoiceHistoryScope,
    required this.deliveryHistoryNote,
    required this.invoiceHistoryNote,
  });
  final String salesOrder;
  final String deliveryHistoryScope, invoiceHistoryScope;
  final String deliveryHistoryNote, invoiceHistoryNote;
  final SalesOrderDetailItem item;
  final List<SalesOrderItemHistory> deliveryNotes, salesInvoices;
  bool get deliveryHistoryRestricted =>
      deliveryHistoryScope == 'no_read_permission';
  bool get invoiceHistoryRestricted =>
      invoiceHistoryScope == 'no_read_permission';
  factory SalesOrderItemDetail.fromJson(Map<String, dynamic> json) {
    final so = json['sales_order'];
    final soName = so is Map ? so['name'] : so;
    List<SalesOrderItemHistory> histories(Object? value) =>
        (value as List? ?? const [])
            .whereType<Map>()
            .map(
              (e) =>
                  SalesOrderItemHistory.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(growable: false);
    final rawScope = json['history_scope'];
    final scopes = rawScope is Map
        ? Map<String, dynamic>.from(rawScope)
        : <String, dynamic>{};
    final rawNote = json['history_note'];
    final notes = rawNote is Map
        ? Map<String, dynamic>.from(rawNote)
        : <String, dynamic>{};
    final commonScope = rawScope is Map ? null : rawScope;
    final commonNote = rawNote is Map ? null : rawNote;
    return SalesOrderItemDetail(
      salesOrder: _text(soName),
      item: SalesOrderDetailItem.fromJson(
        json['item'] is Map
            ? Map<String, dynamic>.from(json['item'])
            : const {},
      ),
      deliveryNotes: histories(json['delivery_notes']),
      salesInvoices: histories(json['sales_invoices']),
      deliveryHistoryScope: _text(
        scopes['delivery_notes'] ?? scopes['delivery_note'] ?? commonScope,
      ),
      invoiceHistoryScope: _text(
        scopes['sales_invoices'] ?? scopes['sales_invoice'] ?? commonScope,
      ),
      deliveryHistoryNote: sanitizeErpText(
        notes['delivery_notes'] ?? notes['delivery_note'] ?? commonNote,
      ),
      invoiceHistoryNote: sanitizeErpText(
        notes['sales_invoices'] ?? notes['sales_invoice'] ?? commonNote,
      ),
    );
  }
}

String _text(Object? value, {String fallback = '-'}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

double _number(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

bool _bool(Object? value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';
