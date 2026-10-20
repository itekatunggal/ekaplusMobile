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
    final itemJson = json['item'] as Map<String, dynamic>? ?? const {};
    final categoryJson = itemJson['item_category'];
    WishlistItemCategory? category;

    if (categoryJson is String && categoryJson.trim().isNotEmpty) {
      category = WishlistItemCategory(id: 0, name: categoryJson.trim());
    } else if (categoryJson is Map<String, dynamic>) {
      final categoryName =
          (categoryJson['category_name'] ?? categoryJson['name'] ?? '')
              .toString()
              .trim();
      if (categoryName.isNotEmpty) {
        category = WishlistItemCategory(
          id: _toInt(categoryJson['id']),
          name: categoryName,
        );
      }
    } else {
      // Tetap mendukung response API yang mengembalikan kategori secara flat.
      final categoryName = (itemJson['category_name'] ?? '').toString().trim();
      if (categoryName.isNotEmpty) {
        category = WishlistItemCategory(
          id: _toInt(itemJson['item_category_id']),
          name: categoryName,
        );
      }
    }

    return WishlistItemModel(
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      id: _toInt(json['id']),
      item: WishlistItemProduct(
        id: _toInt(itemJson['id']),
        image: (itemJson['image'] ?? '').toString(),
        itemCode: (itemJson['item_code'] ?? '').toString(),
        itemName: (itemJson['item_name'] ?? '').toString(),
        category: category,
        uom: (itemJson['uom'] ?? itemJson['stock_uom'] ?? '').toString().trim(),
      ),
      user: WishlistItemUser(
        id: _toInt((json['user'] as Map<String, dynamic>?)?['id']),
        fullName: ((json['user'] as Map<String, dynamic>?)?['full_name'] ?? '')
            .toString(),
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
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
        'uom': item.uom,
        if (item.category != null)
          'item_category': {
            'id': item.category!.id,
            'category_name': item.category!.name,
          },
      },
      'user': {'id': user.id, 'full_name': user.fullName},
    };
  }

  static List<Map<String, dynamic>> toJsonList(List<WishlistItemModel> items) {
    return items.map((e) => e.toJson()).toList();
  }
}
