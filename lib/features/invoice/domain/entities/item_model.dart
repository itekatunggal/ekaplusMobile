import 'package:equatable/equatable.dart';

class ItemCategoryEntity extends Equatable {
  final int id;
  final String itemCode;
  final String itemName;
  final String qty;
  final Date date;
  final String amount;

  const ItemCategoryEntity({required this.id, required this.itemCode, required this.itemName, required this.qty, required this.date, required this.amount });

  @override
  List<Object?> get props => [id, itemCode, itemName, qty, date, amount];
}

class VariantEntity extends Equatable {
  // final int id;
  // final String code;
  // final String name;
  // final String description;
  // final String image;
  final int id;
  final String itemCode;
  final String itemName;
  final String qty;
  final Date date;
  final String amount;

  const VariantEntity({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.date,
    required this.amount
  });

  @override
  List<Object?> get props => [id, itemCode, itemName, qty, date, amount];
}

class InvoiceList extends Equatable {
  final int id;
  final String itemCode;
  final String itemName;
  final String qty;
  final String date;
  final String amount;
  // final ItemCategoryEntity? itemCategory;
  // final List<VariantEntity> variants;
  // final bool isHotDeals;

  const Invoice({
    required this.id,
    required this.itemCode,
    required this.itemName,
    required this.qty,
    required this.date,
    required this.amount
    // this.itemCategory,
    // this.variants = const [],
    // this.isHotDeals = false,
  });

  @override
  List<Object?> get props => [id, itemCode, itemName, qty, date, amount];
}
