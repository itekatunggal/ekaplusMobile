// lib/features/wishlist/data/models/wishlist_item_model.dart
import 'package:ekaplus_ekatunggal/features/report/domain/entities/product_list.dart';

class ProductItemModel extends ProductItem {
  const ProductItemModel({
    required super.id,
    required super.name,
    required super.qty,
    required super.total,
    required super.persen,
  });

  factory ProductItemModel.fromJson(Map<String, dynamic> json) {
    return ProductItemModel(
      id: json['id'],
      item: ProductItemProduct(
        id: json['item']['id'],
        name: json['item']['name'],
        qty: json['item']['qty'] ?? '',
        total: json['item']['total'],
        persen: json['item']['persen'] ?? '',
      ),
    );
  }

  static List<ProductItemModel> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => ProductItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': item.id,
      'item': {
        'id': item.id,
        'name': item.name,
        'qty': item.qty,
        'total': item.total,
        'persen': item.persen,
      },
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<ProductItemModel> items) {
    return items.map((e) => e.toJson()).toList();
  }
}
