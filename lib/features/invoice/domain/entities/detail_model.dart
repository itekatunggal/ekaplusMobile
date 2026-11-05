import 'package:equatable/equatable.dart';

class DetailList extends Equatable {
  final int id;
  final String name;
  final String itemName;
  final DateTime date;
  final String customer;
  final DateTime dueDate;
  final String purchaseOrder;
  final String purchaseDate;
  final String address;
  final String shippingAddressName;
  final String contactPerson;
  final String type;
  final String accountHead;
  final String rate;
  final String amount;
  final String discount;
  final String discountPercent;
  final String discountAmount;

  const DetailList({
    required this.id,
    required this.name,
    required this.itemName,
    required this.date,
    required this.customer,
    required this.dueDate,
    required this.purchaseOrder,
    required this.purchaseDate,
    required this.address,
    required this.shippingAddressName,
    required this.contactPerson,
    required this.type,
    required this.accountHead,
    required this.rate,
    required this.amount,
    required this.discount,
    required this.discountPercent,
    required this.discountAmount,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    itemName,
    date,
    customer,
    dueDate,
    purchaseOrder,
    purchaseDate,
    address,
    shippingAddressName,
    contactPerson,
    type,
    accountHead,
    rate,
    amount,
    discount,
    discountPercent,
    discountAmount,
  ];
}
