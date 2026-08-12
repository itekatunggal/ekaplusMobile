import 'package:equatable/equatable.dart';

class ItemCategoryEntity extends Equatable {
  final int id;
  final Date date;
  final String nilai;

  const ItemCategoryEntity({required this.id, required this.date, required this.nilai});

  @override
  List<Object?> get props => [id, date, nilai];
}

class VariantEntity extends Equatable {
  // final int id;
  // final String code;
  // final String name;
  // final String description;
  // final String image;
  final int id;
  final Date date;
  final String nilai;

  const VariantEntity({
    required this.id,
    required this.date,
    required this.nilai,
  });

  @override
  List<Object?> get props => [id, date, nilai];
}

class PenjualanList extends Equatable {
  final int id;
  final Date date;
  final String nilai;
  // final ItemCategoryEntity? itemCategory;
  // final List<VariantEntity> variants;
  // final bool isHotDeals;

  const Penjualan({
    required this.id,
    required this.date,
    required this.nilai,
    // this.itemCategory,
    // this.variants = const [],
    // this.isHotDeals = false,
  });

  @override
  List<Object?> get props => [id, date, nilai];
}
