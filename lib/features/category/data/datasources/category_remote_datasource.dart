// // lib/features/category/data/datasources/category_remote_datasource.dart

import 'dart:convert';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/category/data/models/category_group_model.dart';
import 'package:ekaplus_ekatunggal/features/category/data/models/category_model.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';
import 'package:http/http.dart' as http;

abstract class CategoryRemoteDatasource {
  Future<List<Category>> getAllCategory(int page);
  Future<List<CategoryGroupModel>> getGroupByType();
  Future<Category> getCategory(String id);
}

class CategoryRemoteDatasourceImplementation extends CategoryRemoteDatasource {
  final http.Client client;

  CategoryRemoteDatasourceImplementation({required this.client});

  @override
  Future<List<CategoryGroupModel>> getGroupByType() async {
    try {
      final spec = {
        "fields": ["id", "type_name"],
        "filters": [
          ["disabled", "=", "0"],
        ],
        "childs": [
          {
            "alias": "categories",
            "table": "ekatalog_category",
            "parent_key": "item_type",
            "parent_value": "id",
            "order_by": [
              ["name", "asc"],
            ],
            "fields": [
              "category_name",
              "icon",
              "id",
              "description",
              "image",
              "subtitle",
              "title",
            ],
          },
        ],
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/resource/ekatalog_type'
        '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
      );

      final response = await client.get(uri, headers: {...ApiConfig.headers});

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data tipe');
      }

      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      List<CategoryGroupModel> result = CategoryGroupModel.fromJsonList(data);

      return result;
    } catch (e) {
      throw Exception('Gagal mengambil data tipe: $e');
    }
  }

  @override
  Future<List<Category>> getAllCategory(int page) async {
    try {
      final spec = {
        "fields": ["id", "category_name", "icon"],
        "filters": [
          ["disabled", "=", "0"],
        ],
        // "childs": [
        //   {
        //     "alias": "categories",
        //     "table": "ekatalog_category",
        //     "parent_key": "item_type",
        //     "parent_value": "id",
        //     "order_by": [
        //       ["name", "asc"],
        //     ],
        //   },
        // ],
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/resource/ekatalog_category'
        '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
      );

      final response = await client.get(uri, headers: {...ApiConfig.headers});

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data tipe');
      }

      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      List<CategoryModel> typeData = CategoryModel.fromJsonList(data);

      return typeData;
    } catch (e) {
      throw Exception('Gagal mengambil data tipe: $e');
    }
  }

  @override
  Future<Category> getCategory(String id) async {
    try {
      final spec = {
        "fields": ["*"],
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/resource/ekatalog_category'
        '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
      );

      final response = await client.get(uri, headers: {...ApiConfig.headers});

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data tipe');
      }

      final body = jsonDecode(response.body);
      final dynamic data = body['data'] ?? [];

      CategoryModel result = CategoryModel.fromJson(data);

      return result;
    } catch (e) {
      throw Exception('Gagal mengambil data tipe: $e');
    }
  }
}
