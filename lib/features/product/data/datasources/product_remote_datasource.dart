// lib/features/product/data/datasources/product_remote_datasource.dart

import 'dart:convert';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';

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

  @override
  Future<List<Product>> getAllProduct({
    int page = 1,
    int limit = 20,
    List<List<dynamic>>? filters,
    List<String>? fields,
    List<List<String>>? orderBy,
    String? search,
  }) async {
    try {
      final spec = <String, dynamic>{
        "fields": fields ?? ["id", "product_name"],
        "limit": limit,
        "page": page,
        "childs": [
          {
            "alias": "variants",
            "table": "ekatalog_variant",
            "fields": ["item.id", "item.image"],
            "limit": 1,
            "order_by": [
              ["item.updated_at", "desc"],
            ],
          },
        ],
      };

      List<List<dynamic>> finalFilter = [];

      if (filters != null && filters.isNotEmpty) {
        finalFilter.addAll(filters);
      }

      finalFilter.addAll([
        ["disabled", "=", "0"],
        // ["variants.item.disabled", "=", "0"],
        // ["variants.item.image", "is", "set"],
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

      final response = await http.get(uri, headers: {...ApiConfig.headers});

      if (response.statusCode != 200) {
        throw response.body;
      }

      final decoded = jsonDecode(response.body);

      final List<dynamic> data = decoded is List
          ? decoded
          : (decoded['data'] ?? []);

      List<Product> result = ProductModel.fromJsonList(data);

      return result;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Product> getProduct(String id) async {
    try {
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
            ],
            "order_by": [
              ["item.updated_at", "desc"],
            ],
          },
        ],
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/resource/ekatalog_product/$id'
        '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
      );
      final response = await http.get(uri, headers: {...ApiConfig.headers});

      if (response.statusCode != 200) {
        throw response.body;
      }

      final decoded = jsonDecode(response.body);

      final dynamic data = decoded is List ? decoded : (decoded['data'] ?? []);

      return ProductModel.fromJson(data);
    } catch (e) {
      throw e.toString();
    }
  }
}
