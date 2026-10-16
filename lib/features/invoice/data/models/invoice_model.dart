class Invoice {
  final String name;
  final String customer;
  final String customerName;
  final String postingDate;
  final String dueDate;         
  final String status;
  final double grandTotal;
  final double outstandingAmount; 
  final String currency;

  const Invoice({
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

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      name: json['name'] ?? '',
      customer: json['customer'] ?? '',
      customerName: json['customer_name'] ?? '',
      postingDate: json['posting_date'] ?? '',
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? '',
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0,
      outstandingAmount: (json['outstanding_amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] ?? '',
    );
  }
}
