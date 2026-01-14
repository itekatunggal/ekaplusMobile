// lib/features/wishlist/data/models/wishlist_item_model.dart
import 'package:ekaplus_ekatunggal/features/wishlist/domain/entities/wishlist_item.dart';

class WishlistItemModel extends WishlistItem {
  const WishlistItemModel({
    required super.id,
    required super.createdAt,
    required super.item,
    required super.user,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) {
    return WishlistItemModel(
      createdAt: DateTime.parse(json['created_at']),
      id: json['id'],
      item: WishlistItemProduct(
        id: json['item']['id'],
        image: json['item']['image'] ?? '',
        itemCode: json['item']['item_code'] ?? '',
        itemName: json['item']['item_name'] ?? '',
      ),
      user: WishlistItemUser(
        id: json['user']['id'],
        fullName: json['user']['full_name'] ?? '',
      ),
    );
  }

  static List<WishlistItemModel> fromJsonList(List<dynamic> list) {
    return list
        .map((e) => WishlistItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': item.id,
      'created_at': createdAt.toIso8601String(),
      'item': {
        'id': item.id,
        'image': item.image,
        'item_code': item.itemCode,
        'item_name': item.itemName,
      },
      'user': {'id': user.id, 'full_name': user.fullName},
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<WishlistItemModel> items) {
    return items.map((e) => e.toJson()).toList();
  }
}
