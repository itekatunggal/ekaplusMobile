import 'package:equatable/equatable.dart';

class ItemCategoryEntity extends Equatable {
  final int id;
  final String name;
  final String paymentType;
  final Date postingDate;
  final String customer;
  final String paidAmount;
  final String salesInvoiceName;
  final Date dueDate;
  final String grandTotal;
  final String outstandingAmount;
  final String allocatedAmount;

  const ItemCategoryEntity({required this.id, required this.name, required this.paymentType, required this.postingDate, required this.customer, required this.paidAmount, required this.salesInvoiceName, required this.dueDate, required this.grandTotal, required this.outstandingAmount, required this.allocatedAmount });

  @override
  List<Object?> get props => [id, name, paymentType, postingDate, customer, paidAmount, salesInvoiceName, dueDate, grandTotal, oustandingAmount, allocatedAmount];
}

class VariantEntity extends Equatable {
  // final int id;
  // final String code;
  // final String name;
  // final String description;
  // final String image;
  final int id;
  final String name;
  final String paymentType;
  final Date postingDate;
  final String customer;
  final String paidAmount;
  final String salesInvoiceName;
  final Date dueDate;
  final String grandTotal;
  final String outstandingAmount;
  final String allocatedAmount;

  const VariantEntity({
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
  List<Object?> get props => [id, name, paymentType, postingDate, customer, paidAmount, salesInvoiceName, dueDate, grandTotal, oustandingAmount, allocatedAmount];
}

class PembayaranList extends Equatable {
  final int id;
  final String name;
  final String paymentType;
  final Date postingDate;
  final String customer;
  final String paidAmount;
  final String salesInvoiceName;
  final Date dueDate;
  final String grandTotal;
  final String outstandingAmount;
  final String allocatedAmount;
  // final ItemCategoryEntity? itemCategory;
  // final List<VariantEntity> variants;
  // final bool isHotDeals;

  const Pembayaran({
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
    // this.itemCategory,
    // this.variants = const [],
    // this.isHotDeals = false,
  });

  @override
  List<Object?> get props => [id, name, paymentType, postingDate, customer, paidAmount, salesInvoiceName, dueDate, grandTotal, oustandingAmount, allocatedAmount];
}
