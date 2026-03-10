// // lib/features/category/data/datasources/category_remote_datasource.dart

import 'dart:convert';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/network/http_request_handler.dart';
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

  bool _isDisabled(dynamic value) {
    if (value is num) return value == 1;
    final raw = value?.toString().trim().toLowerCase() ?? '';
    return raw == '1' || raw == 'true' || raw == 'disabled';
  }

  List<dynamic> _filterEnabledCategories(List<dynamic> rows) {
    return rows.where((row) {
      if (row is! Map<String, dynamic>) return false;
      final disabled = _isDisabled(row['disabled']);
      final status = _isDisabled(row['status']);
      return !disabled && !status;
    }).toList();
  }

  List<dynamic> _sanitizeTypeGroups(List<dynamic> rows) {
    return rows.map((row) {
      if (row is! Map<String, dynamic>) return row;
      final categoriesRaw = row['categories'];
      if (categoriesRaw is! List) return row;

      return {...row, 'categories': _filterEnabledCategories(categoriesRaw)};
    }).toList();
  }

  @override
  Future<List<CategoryGroupModel>> getGroupByType() async {
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
            "disabled",
            "status",
          ],
          "filters": [
            ["disabled", "=", "0"],
          ],
        },
      ],
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/ekatalog_type'
      '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
    );

    final response = await HttpRequestHandler.send(
      () => client.get(uri, headers: {...ApiConfig.headers}),
      defaultServerMessage: 'Gagal mengambil data kategori',
    );

    final body = jsonDecode(response.body);
    final List<dynamic> data = body['data'] ?? [];
    final sanitized = _sanitizeTypeGroups(data);

    return CategoryGroupModel.fromJsonList(sanitized);
  }

  @override
  Future<List<Category>> getAllCategory(int page) async {
    final spec = {
      "fields": ["id", "category_name", "icon", "disabled", "status"],
      "filters": [
        ["disabled", "=", "0"],
      ],
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/ekatalog_category'
      '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
    );

    final response = await HttpRequestHandler.send(
      () => client.get(uri, headers: {...ApiConfig.headers}),
      defaultServerMessage: 'Gagal mengambil data kategori',
    );

    final body = jsonDecode(response.body);
    final List<dynamic> data = body['data'] ?? [];
    final sanitized = _filterEnabledCategories(data);

    return CategoryModel.fromJsonList(sanitized);
  }

  @override
  Future<Category> getCategory(String id) async {
    final spec = {
      "fields": ["*"],
      "filters": [
        ["id", "=", id],
        ["disabled", "=", "0"],
      ],
      "limit": 1,
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/ekatalog_category'
      '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
    );

    final response = await HttpRequestHandler.send(
      () => client.get(uri, headers: {...ApiConfig.headers}),
      defaultServerMessage: 'Gagal mengambil detail kategori',
    );

    final body = jsonDecode(response.body);
    final list = body['data'];
    if (list is! List || list.isEmpty) {
      throw const FormatException('Kategori tidak ditemukan atau nonaktif');
    }
    final dynamic data = list.first;

    return CategoryModel.fromJson(data);
  }
}
