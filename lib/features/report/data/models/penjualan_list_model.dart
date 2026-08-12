// lib/features/wishlist/data/models/wishlist_item_model.dart
import 'package:ekaplus_ekatunggal/features/report/domain/entities/penjualan_list.dart';

class PenjualanItemModel extends PenjualanItem {
  const WishlistItemModel({
    required super.id,
    required super.date,
    required super.nilai,
  });

  factory PenjualanItemModel.fromJson(Map<String, dynamic> json) {
    return PenjualanItemModel(
      createdAt: DateTime.parse(json['date']),
      id: json['id'],
      item: WishlistItemProduct(
        id: json['item']['id'],
        nilai: json['nilai']['nilai'] ?? '',
      ),
    );
  }

  static List<PenjualanItemModel> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => PenjualanItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': item.id,
      'date': date.toIso8601String(),
      'item': {
        'id': item.id,
        'nilai': item.nilai,
      },
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<PenjualanItemModel> items) {
    return items.map((e) => e.toJson()).toList();
  }
}
