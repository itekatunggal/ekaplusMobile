// // lib/features/category/data/datasources/category_remote_datasource.dart

import 'dart:convert';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/network/http_request_handler.dart';
import 'package:ekaplus_ekatunggal/core/network/resource_visibility.dart';
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

    final response = await HttpRequestHandler.send(
      () => client.get(uri, headers: {...ApiConfig.headers}),
      defaultServerMessage: 'Gagal mengambil data cabang',
    );

    final body = jsonDecode(response.body);
    final List<dynamic> data = body['data'] ?? [];
    final visibleRows = ResourceVisibility.filterVisibleRows(data);

    return BranchModel.fromJsonList(visibleRows);
  }

  @override
  Future<Branch> getBranch(int id) async {
    final spec = {
      "fields": ["*"],
      "filters": [
        ["id", "=", "$id"],
        ["disabled", "=", "0"],
      ],
      "limit": 1,
    };
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/branch'
      '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
    );

    final response = await HttpRequestHandler.send(
      () => client.get(uri, headers: {...ApiConfig.headers}),
      defaultServerMessage: 'Gagal mengambil detail cabang',
    );

    final body = jsonDecode(response.body);
    final list = body['data'];
    if (list is! List || list.isEmpty) {
      throw const FormatException('Cabang tidak ditemukan atau nonaktif');
    }
    final visibleRows = ResourceVisibility.filterVisibleRows(list);
    if (visibleRows.isEmpty) {
      throw const FormatException('Cabang tidak ditemukan atau nonaktif');
    }
    final dynamic data = visibleRows.first;

    return BranchModel.fromJson(data);
  }
}
