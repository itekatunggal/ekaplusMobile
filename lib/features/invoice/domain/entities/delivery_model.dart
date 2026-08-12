import 'package:equatable/equatable.dart';

class ItemCategoryEntity extends Equatable {
  final int id;
  final String name;
  final String customer;
  final Date date;
  final String status;

  const ItemCategoryEntity({required this.id, required this.name, required this.customer, required this.date, required this.status });

  @override
  List<Object?> get props => [id, name, customer, date, status];
}

class VariantEntity extends Equatable {
  // final int id;
  // final String code;
  // final String name;
  // final String description;
  // final String image;
  final int id;
  final String name;
  final String customer;
  final Date date;
  final String status;

  const VariantEntity({
    required this.id,
    required this.name,
    required this.customer,
    required this.date,
    required this.status
  });

  @override
  List<Object?> get props => [id, name, customer, date, status];
}

class InvoiceList extends Equatable {
  final int id;
  final String name;
  final String customer;
  final String date;
  final String status;
  // final ItemCategoryEntity? itemCategory;
  // final List<VariantEntity> variants;
  // final bool isHotDeals;

  const Invoice({
    required this.id,
    required this.name,
    required this.customer,
    required this.date,
    required this.status
    // this.itemCategory,
    // this.variants = const [],
    // this.isHotDeals = false,
  });

  @override
  List<Object?> get props => [id, name, customer, date, status];
}
