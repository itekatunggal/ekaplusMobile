// // lib/features/category/data/datasources/category_remote_datasource.dart

import 'dart:convert';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/network/http_request_handler.dart';
import 'package:ekaplus_ekatunggal/core/network/resource_visibility.dart';
import 'package:ekaplus_ekatunggal/features/banner/data/models/banner_model.dart';
import 'package:ekaplus_ekatunggal/features/banner/domain/entities/bannerslider.dart';

import 'package:http/http.dart' as http;

abstract class BannerRemoteDatasource {
  Future<List<BannerSlider>> getAllBanner(int page);
  Future<BannerSlider> getBanner(String id);
}

class BannerRemoteDatasourceImplementation extends BannerRemoteDatasource {
  final http.Client client;

  BannerRemoteDatasourceImplementation({required this.client});

  @override
  Future<List<BannerSlider>> getAllBanner(int page) async {
    final spec = {
      "fields": ["*"],
      "filters": [
        ["disabled", "=", "0"],
      ],
    };

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/ekatalog_banner'
      '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
    );

    final response = await HttpRequestHandler.send(
      () => client.get(uri, headers: {...ApiConfig.headers}),
      defaultServerMessage: 'Gagal mengambil data banner',
    );

    final body = jsonDecode(response.body);
    final List<dynamic> data = body['data'] ?? [];
    final visibleRows = ResourceVisibility.filterVisibleRows(data);

    return BannerModel.fromJsonList(visibleRows);
  }

  @override
  Future<BannerSlider> getBanner(String id) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/ekatalog_category/$id',
    );

    final response = await HttpRequestHandler.send(
      () => client.get(uri, headers: {...ApiConfig.headers}),
      defaultServerMessage: 'Gagal mengambil detail banner',
    );

    final body = jsonDecode(response.body);
    final dynamic rawData = body['data'] ?? [];
    if (rawData is! Map<String, dynamic>) {
      throw const FormatException('Banner tidak ditemukan');
    }
    if (!ResourceVisibility.isVisibleRecord(rawData)) {
      throw const FormatException('Banner tidak ditemukan atau nonaktif');
    }

    return BannerModel.fromJson(rawData);
  }
}
