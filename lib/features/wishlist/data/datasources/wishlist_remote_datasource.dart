// lib/features/wishlist/data/datasources/wishlist_local_datasource.dart

import 'package:ekaplus_ekatunggal/core/network/base_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/core/network/query_spec_builder.dart';
import 'package:ekaplus_ekatunggal/core/network/resource_visibility.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/data/models/wishlist_item_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class WishlistRemoteDataSource {
  Future<List<WishlistItemModel>> getWishlist(
    int userId,
    int? productId, {
    int? page,
    int? limit,
    String? search,
    List<List<dynamic>>? filters,
    List<List<String>>? orderBy,
    List<String>? fields,
  });

  Future<void> addToWishlist(int userId, int productId);
  Future<void> removeFromWishlist(int userId, int productId);
  Future<bool> isInWishlist(int userId, int productId);
  Future<int> bulkDeleteWishlist(int userId, List<int> productIds);
}

class WishlistLocalDataSourceImpl implements WishlistRemoteDataSource {
  final http.Client client;

  WishlistLocalDataSourceImpl({required this.client});

  @override
  Future<List<WishlistItemModel>> getWishlist(
    int userId,
    int? productId, {
    int? page,
    int? limit,
    String? search,
    List<List<dynamic>>? filters,
    List<List<String>>? orderBy,
    List<String>? fields,
  }) async {
    final ds = BaseRemoteDatasource(Resource.wishlist);

    final spec = QuerySpecBuilder();

    // Fields
    if (fields != null && fields.isNotEmpty) {
      spec.fields(fields);
    } else {
      spec.fields([
        "id",
        "item.item_name",
        "item.id",
        "item.item_code",
        "item.image",
        "item.disabled",
        "item.status",
        "user.id",
        "user.full_name",
        "created_at",
      ]);
    }

    // Filter by user
    spec.where("user", "=", userId);
    spec.where("item.disabled", "=", 0);

    // Filter by productId jika ada
    if (productId != null) {
      spec.where("item", "=", productId);
    }

    // Custom filters
    if (filters != null && filters.isNotEmpty) {
      for (final filter in filters) {
        if (filter.length >= 3) {
          spec.where(filter[0].toString(), filter[1].toString(), filter[2]);
        }
      }
    }

    // Search
    if (search != null && search.isNotEmpty) {
      spec.where("item.item_name", "like", "%$search%");
    }

    // Order by
    if (orderBy != null && orderBy.isNotEmpty) {
      for (final order in orderBy) {
        if (order.length >= 2) {
          // ✅ Gunakan named parameter 'direction'
          spec.orderBy(order[0], direction: order[1]);
        }
      }
    }

    // Pagination - gunakan page() method yang sudah ada
    if (page != null) {
      spec.page(page);
    }

    if (limit != null) {
      spec.limit(limit);
    } else {
      spec.limit(0); // No limit
    }

    final response = await ds.FINDALL(
      query: {'spec': jsonEncode(spec.build())},
    );

    final decoded = jsonDecode(response.body);

    final List<dynamic> data = decoded is List
        ? decoded
        : (decoded['data'] ?? []);
    final visibleRows = data.whereType<Map<String, dynamic>>().where((row) {
      final item = row['item'];
      if (item is! Map<String, dynamic>) return false;
      return ResourceVisibility.isVisibleRecord(item);
    }).toList();

    return WishlistItemModel.fromJsonList(visibleRows);
  }

  @override
  Future<void> addToWishlist(int userId, int productId) async {
    final ds = BaseRemoteDatasource(Resource.wishlist);

    final alreadyExists = await isInWishlist(userId, productId);
    if (alreadyExists) {
      return;
    }

    final body = jsonEncode({"user": userId, "item": productId});

    await ds.ADD(body);
  }

  @override
  Future<void> removeFromWishlist(int userId, int productId) async {
    final ds = BaseRemoteDatasource(Resource.wishlist);

    final wishlist = await getWishlist(userId, productId);

    if (wishlist.isEmpty) {
      return;
    }

    final response = await ds.DELETEONE(wishlist.first.id.toString());
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(response.body);
    }
  }

  @override
  Future<bool> isInWishlist(int userId, int productId) async {
    final wishlist = await getWishlist(userId, productId);
    return wishlist.isNotEmpty;
  }

  @override
  Future<int> bulkDeleteWishlist(int userId, List<int> productIds) async {
    if (productIds.isEmpty) return 0;

    final ds = BaseRemoteDatasource(Resource.wishlist);

    final spec = QuerySpecBuilder().where("user", "=", userId).limit(0);

    for (final id in productIds) {
      spec.where("item", "=", id);
    }

    final response = await ds.FINDALL(
      query: {'spec': jsonEncode(spec.build())},
    );

    final decoded = jsonDecode(response.body);
    final List data = decoded is List ? decoded : (decoded['data'] ?? []);

    var deleted = 0;

    for (final row in data) {
      final res = await ds.DELETEONE(row['id'].toString());

      if (res.statusCode == 200 || res.statusCode == 204) {
        deleted++;
      } else {
        throw Exception('Failed delete wishlist id=${row['id']}');
      }
    }

    return deleted;
  }
}
