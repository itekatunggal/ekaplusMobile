import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';

class ItemCategoryModel extends ItemCategoryEntity {
  const ItemCategoryModel({required super.id, required super.name});

  factory ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    return ItemCategoryModel(
      id: json['id'] ?? 0,
      name: json['category_name'] ?? '',
    );
  }
}

class VariantModel extends VariantEntity {
  const VariantModel({
    required super.id,
    required super.code,
    required super.name,
    required super.description,
    required super.image,
    super.length,
    super.width,
    super.height,
    super.weight,
    super.standardCollyItem,
    super.uom,
  });

  static num? _toNum(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    final item = json['item'] as Map<String, dynamic>?;

    return VariantModel(
      id: item?['id'] ?? 0,
      code: item?['item_code'] ?? '',
      name: item?['item_name'] ?? '',
      description: item?['item_desc'] ?? '',
      image: item?['image'] ?? '',
      length: _toNum(item?['length']),
      width: _toNum(item?['width']),
      height: _toNum(item?['height']),
      weight: _toNum(item?['weight']),
      standardCollyItem: _toNum(item?['standard_colly_item']),
      uom: item?['uom']?.toString(),
    );
  }
}

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    super.itemCategory,
    super.variants,
    super.isHotDeals,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // item category
    ItemCategoryEntity? category;
    if (json['item_category'] is Map<String, dynamic>) {
      category = ItemCategoryModel.fromJson(json['item_category']);
    }

    // variants
    final variants = (json['variants'] as List<dynamic>? ?? [])
        .map((v) => VariantModel.fromJson(v))
        .toList();

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['product_name'] ?? '',
      itemCategory: category,
      variants: variants,
      isHotDeals: json['hot_deals'] == 1,
    );
  }

  static List<ProductModel> fromJsonList(List data) {
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }
}
