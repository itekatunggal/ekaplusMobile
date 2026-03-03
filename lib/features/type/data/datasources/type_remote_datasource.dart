import 'dart:convert';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/network/resource_visibility.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:ekaplus_ekatunggal/features/type/data/models/type_model.dart';
import 'package:ekaplus_ekatunggal/features/type/domain/entities/type.dart';
import 'package:http/http.dart' as http;

abstract class TypeRemoteDatasource {
  Future<List<Type>> getAllType(int page);
  Future<Type> getType(String id);
}

class TypeRemoteDatasourceImpl implements TypeRemoteDatasource {
  final http.Client client;

  TypeRemoteDatasourceImpl({required this.client});

  @override
  Future<List<Type>> getAllType(int page) async {
    try {
      final spec = {
        "fields": ["*"],
        "filters": [
          ["disabled", "=", "0"],
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
      final visibleRows = ResourceVisibility.filterVisibleRows(data);

      List<TypeModel> typeData = TypeModel.fromJsonList(visibleRows);

      return typeData;
    } catch (e) {
      throw Exception('Gagal mengambil data tipe: $e');
    }
  }

  @override
  Future<Type> getType(String id) async {
    final raw = await rootBundle.loadString('assets/data/itemType.json');
    final decoded = jsonDecode(raw);

    final List<dynamic> list = decoded is List
        ? decoded
        : decoded['data'] ?? [];

    final found = list.firstWhere(
      (e) => e['id'].toString() == id,
      orElse: () => null,
    );

    if (found == null) {
      throw Exception('Data not found');
    }

    return TypeModel.fromJson(found);
  }
}
