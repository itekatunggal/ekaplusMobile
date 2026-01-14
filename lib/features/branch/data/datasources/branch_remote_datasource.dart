// // lib/features/category/data/datasources/category_remote_datasource.dart

import 'dart:convert';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/features/branch/data/models/branch_model.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:http/http.dart' as http;

abstract class BranchRemoteDatasource {
  Future<List<Branch>> getAllBranches(int page);
  Future<Branch> getBranch(int id);
}

class BranchRemoteDatasourceImplementation extends BranchRemoteDatasource {
  final http.Client client;

  BranchRemoteDatasourceImplementation({required this.client});

  @override
  Future<List<Branch>> getAllBranches(int page) async {
    try {
      final spec = {
        "fields": ["*"],
        "filters": [
          ["disabled", "=", "0"],
        ],
      };

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/resource/branch'
        '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
      );

      final response = await client.get(uri, headers: {...ApiConfig.headers});

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data tipe');
      }

      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      List<Branch> result = BranchModel.fromJsonList(data);

      return result;
    } catch (e) {
      throw Exception('Gagal mengambil data: $e');
    }
  }

  @override
  Future<Branch> getBranch(int id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/api/resource/branch/$id');

      final response = await client.get(uri, headers: {...ApiConfig.headers});

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data tipe');
      }

      final body = jsonDecode(response.body);
      final dynamic data = body['data'] ?? [];

      Branch result = BranchModel.fromJson(data);

      return result;
    } catch (e) {
      throw Exception('Gagal mengambil data tipe: $e');
    }
  }
}
