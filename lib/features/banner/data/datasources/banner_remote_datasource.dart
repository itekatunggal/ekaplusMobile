// // lib/features/category/data/datasources/category_remote_datasource.dart

import 'dart:convert';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
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
    try {
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

      final response = await client.get(uri, headers: {...ApiConfig.headers});

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data tipe');
      }

      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];
      final visibleRows = ResourceVisibility.filterVisibleRows(data);

      List<BannerModel> bannerData = BannerModel.fromJsonList(visibleRows);

      return bannerData;
    } catch (e) {
      throw Exception('Gagal mengambil data tipe: $e');
    }
  }

  @override
  Future<BannerSlider> getBanner(String id) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/resource/ekatalog_category/$id',
      );

      final response = await client.get(uri, headers: {...ApiConfig.headers});

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data tipe');
      }

      final body = jsonDecode(response.body);
      final dynamic rawData = body['data'] ?? [];
      if (rawData is! Map<String, dynamic>) {
        throw Exception('Banner tidak ditemukan');
      }
      if (!ResourceVisibility.isVisibleRecord(rawData)) {
        throw Exception('Banner tidak ditemukan atau nonaktif');
      }

      BannerModel result = BannerModel.fromJson(rawData);

      return result;
    } catch (e) {
      throw Exception('Gagal mengambil data tipe: $e');
    }
  }
}
