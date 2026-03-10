// lib/features/product/data/datasources/product_remote_datasource.dart

import 'dart:convert';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/network/http_request_handler.dart';
import 'package:ekaplus_ekatunggal/core/network/resource_visibility.dart';

import 'package:ekaplus_ekatunggal/features/product/data/models/product_model.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:http/http.dart' as http;

abstract class ProductRemoteDatasource {
  Future<List<Product>> getAllProduct({
    int page = 1,
    int limit = 20,
    List<List<dynamic>>? filters,
    List<String>? fields,
    List<List<String>>? orderBy,
    String? search,
  });
  Future<Product> getProduct(String id);
}

class ProductRemoteDatasourceImplementation extends ProductRemoteDatasource {
  final http.Client client;

  ProductRemoteDatasourceImplementation({required this.client});

  List<dynamic> _filterVisibleVariants(List<dynamic> variants) {
    return variants.where((variant) {
      if (variant is! Map<String, dynamic>) return false;
      final item = variant['item'];
      if (item is! Map<String, dynamic>) return false;
      return ResourceVisibility.isVisibleRecord(item);
    }).toList();
  }

  List<Map<String, dynamic>> _sanitizeProducts(List<dynamic> data) {
    return data
        .whereType<Map<String, dynamic>>()
        .where((row) {
          return ResourceVisibility.isVisibleRecord(row);
        })
        .map((row) {
          final variants = row['variants'];
          if (variants is! List) return row;
          return {...row, 'variants': _filterVisibleVariants(variants)};
        })
        .toList();
  }

  @override
  Future<List<Product>> getAllProduct({
    int page = 1,
    int limit = 20,
    List<List<dynamic>>? filters,
    List<String>? fields,
    List<List<String>>? orderBy,
    String? search,
  }) async {
    final spec = <String, dynamic>{
      "fields": fields ?? ["id", "product_name", "disabled", "status"],
      "limit": limit,
      "page": page,
      "childs": [
        {
          "alias": "variants",
          "table": "ekatalog_variant",
          "fields": ["item.id", "item.image", "item.disabled", "item.status"],
          "limit": 1,
          "order_by": [
            ["item.updated_at", "desc"],
          ],
        },
      ],
    };

    final finalFilter = <List<dynamic>>[];

    if (filters != null && filters.isNotEmpty) {
      finalFilter.addAll(filters);
    }

    finalFilter.addAll([
      ["disabled", "=", "0"],
    ]);

    spec["filters"] = finalFilter;

    if (orderBy != null && orderBy.isNotEmpty) {
      spec["order_by"] = orderBy;
    }

    if (search != null && search.trim().isNotEmpty) {
      spec["search"] = search;
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/ekatalog_product'
      '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
    );

    final response = await HttpRequestHandler.send(
      () => client.get(uri, headers: {...ApiConfig.headers}),
      defaultServerMessage: 'Gagal mengambil data produk',
    );

    final decoded = jsonDecode(response.body);

    final List<dynamic> data = decoded is List
        ? decoded
        : (decoded['data'] ?? []);
    final sanitized = _sanitizeProducts(data);

    return ProductModel.fromJsonList(sanitized);
  }

  @override
  Future<Product> getProduct(String id) async {
    final spec = {
      "fields": [
        "product_name",
        "id",
        "item_category",
        "hot_deals",
        "item_category.category_name",
        "item_category.id",
      ],
      "childs": [
        {
          "alias": "variants",
          "table": "ekatalog_variant",
          "fields": [
            "item.id",
            "item.item_code",
            "item.item_name",
            "item.image",
            "item.item_desc",
            "item.disabled",
            "item.status",
          ],
          "order_by": [
            ["item.updated_at", "desc"],
          ],
        },
      ],
      "filters": [
        ["id", "=", id],
        ["disabled", "=", "0"],
      ],
      "limit": 1,
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/ekatalog_product/$id'
      '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
    );
    final response = await HttpRequestHandler.send(
      () => client.get(uri, headers: {...ApiConfig.headers}),
      defaultServerMessage: 'Gagal mengambil detail produk',
    );

    final decoded = jsonDecode(response.body);

    final dataList = decoded is List ? decoded : (decoded['data'] ?? []);
    if (dataList is! List || dataList.isEmpty) {
      throw const FormatException('Produk tidak ditemukan atau nonaktif');
    }
    final sanitized = _sanitizeProducts(dataList);
    if (sanitized.isEmpty) {
      throw const FormatException('Produk tidak ditemukan atau nonaktif');
    }
    final dynamic data = sanitized.first;

    return ProductModel.fromJson(data);
  }
}
