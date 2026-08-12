class SalesOrder {
  final String name;
  final String customer;
  final String customerName;
  final String postingDate;
  final String dueDate;         
  final String status;
  final double grandTotal;
  final double outstandingAmount; 
  final String currency;

  const SalesOrder({
    required this.name,
    required this.customer,
    required this.customerName,
    required this.postingDate,
    this.dueDate = '',
    required this.status,
    required this.grandTotal,
    this.outstandingAmount = 0,
    required this.currency,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      name: json['name'] ?? '',
      customer: json['customer'] ?? '',
      customerName: json['customer_name'] ?? '',
      postingDate: json['posting_date'] ?? '',
      dueDate: json['transaction_date'] ?? '-',
      status: json['status'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0,
      outstandingAmount: (json['outstanding_amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] ?? '',
    );
  }
}