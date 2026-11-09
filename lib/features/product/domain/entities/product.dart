import 'package:equatable/equatable.dart';

class ItemCategoryEntity extends Equatable {
  final int id;
  final String name;

  const ItemCategoryEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class VariantEntity extends Equatable {
  final int id;
  final String code;
  final String name;
  final String description;
  final String image;
  final num? length;
  final num? width;
  final num? height;
  final num? weight;
  final num? standardCollyItem;
  final String? uom;

  const VariantEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.image,
    this.length,
    this.width,
    this.height,
    this.weight,
    this.standardCollyItem,
    this.uom,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    description,
    image,
    length,
    width,
    height,
    weight,
    standardCollyItem,
    uom,
  ];
}

class Product extends Equatable {
  final int id;
  final String name;
  final ItemCategoryEntity? itemCategory;
  final List<VariantEntity> variants;
  final bool isHotDeals;

  const Product({
    required this.id,
    required this.name,
    this.itemCategory,
    this.variants = const [],
    this.isHotDeals = false,
  });

  @override
  List<Object?> get props => [id, name, itemCategory, variants, isHotDeals];
}
