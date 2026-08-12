import 'package:equatable/equatable.dart';

class ItemCategoryEntity extends Equatable {
  final int id;
  final String name;
  final int qty;
  final String total;
  final String persen;

  const ItemCategoryEntity({required this.id, required this.name, required this.total, required this.persen});

  @override
  List<Object?> get props => [id, name, qty, total, persen];
}

class VariantEntity extends Equatable {
  // final int id;
  // final String code;
  // final String name;
  // final String description;
  // final String image;
  final int id;
  final String name;
  final int qty;
  final String total;
  final String persen;

  const VariantEntity({
    required this.id,
    required this.name,
    required this.qty,
    required this.total,
    required this.persen
  });

  @override
  List<Object?> get props => [id, name, qty, total, persen];
}

class PenjualanList extends Equatable {
  final int id;
  final String name;
  final int qty;
  final String total;
  final String persen;
  // final ItemCategoryEntity? itemCategory;
  // final List<VariantEntity> variants;
  // final bool isHotDeals;

  const Penjualan({
    required this.id,
    required this.name,
    required this.qty,
    required this.total,
    required this.persen,
    // this.itemCategory,
    // this.variants = const [],
    // this.isHotDeals = false,
  });

  @override
  List<Object?> get props => [id, name, qty, total, persen];
}
