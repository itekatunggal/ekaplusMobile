import 'package:equatable/equatable.dart';

class PembayaranList extends Equatable {
  final int id;
  final String name;
  final String paymentType;
  final DateTime postingDate;
  final String customer;
  final String paidAmount;
  final String salesInvoiceName;
  final DateTime dueDate;
  final String grandTotal;
  final String outstandingAmount;
  final String allocatedAmount;

  const PembayaranList({
    required this.id,
    required this.name,
    required this.paymentType,
    required this.postingDate,
    required this.customer,
    required this.paidAmount,
    required this.salesInvoiceName,
    required this.dueDate,
    required this.grandTotal,
    required this.outstandingAmount,
    required this.allocatedAmount,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    paymentType,
    postingDate,
    customer,
    paidAmount,
    salesInvoiceName,
    dueDate,
    grandTotal,
    outstandingAmount,
    allocatedAmount,
  ];
}
