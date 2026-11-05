import 'package:ekaplus_ekatunggal/features/report/domain/entities/product_list.dart';

class ProductListModel extends ProductList {
  const ProductListModel({
    required super.id,
    required super.name,
    required super.qty,
    required super.total,
    required super.persen,
  });

  factory ProductListModel.fromJson(Map<String, dynamic> json) {
    return ProductListModel(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      total: json['total']?.toString() ?? '',
      persen: json['persen']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'qty': qty,
    'total': total,
    'persen': persen,
  };

  static List<ProductListModel> fromJsonList(List<dynamic> list) => list
      .map((item) => ProductListModel.fromJson(item as Map<String, dynamic>))
      .toList();
}
