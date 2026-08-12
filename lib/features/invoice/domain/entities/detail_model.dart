import 'package:equatable/equatable.dart';

class ItemCategoryEntity extends Equatable {
  final int id;
  final String name;
  final Date date;
  final String customer;
  final Date duedate;
  final String purchaseOrder;
  final String purchaseOrder;
  final Date purchaseDate;
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
  const ItemCategoryEntity({required this.id, required this.name, required this.date, required this.customer, required this.dueDate, required this.purchaseOrder, required this.purchaseDate, required this.purchaseOrder, required this.purchaseDate, required this.address, required this.shippingAddressName, required this.contactPerson, required this.type, required this.accountHead, required this.rate, required this.amount, required this.discount, required this.discountPercent, required this.discountAmount });

  @override
  List<Object?> get props => [id, name, date, customer, duedate, purchaseOrder, purchaseDate, address, shippingAddressName, contactPerson, type, accountHead, rate, amount, discount, discountPercent, discountAmount];
}

class VariantEntity extends Equatable {
  // final int id;
  // final String code;
  // final String name;
  // final String description;
  // final String image;
  final int id;
  final String name;
  final String itemName;
  final Date date;
  final String customer;
  final Date duedate;
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

  const VariantEntity({
    required this.id,
    required this.name,
    required this.date,
    required this.customer,
    required this.duedate,
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
  List<Object?> get props => [id, name, date, customer, duedate, purchaseOrder, purchaseDate, address, shippingAddressName, contactPerson, type, accountHead, rate, amount, discount, discountPercent, discountAmount];
}

class DetailList extends Equatable {
  final int id;
  final String name;
  final String itemName;
  final Date date;
  final String customer;
  final Date duedate;
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
  // final ItemCategoryEntity? itemCategory;
  // final List<VariantEntity> variants;
  // final bool isHotDeals;

  const Detail({
    required this.id,
    required this.name,
    required this.date,
    required this.customer,
    required this.duedate,
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
    // this.itemCategory,
    // this.variants = const [],
    // this.isHotDeals = false,
  });

  @override
  List<Object?> get props => [id, name, date, customer, duedate, purchaseOrder, purchaseDate, address, shippingAddressName, contactPerson, type, accountHead, rate, amount, discount, discountPercent, discountAmount];
}
