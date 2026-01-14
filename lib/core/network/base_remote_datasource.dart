// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';

enum Resource { wishlist }

const Map<Resource, String> _resourcePath = {Resource.wishlist: 'wishlist'};

class BaseRemoteDatasource {
  final Resource resource;

  BaseRemoteDatasource(this.resource);

  String get _doc => _resourcePath[resource]!;

  Future<Map<String, String>> _headers() async {
    final token = await SessionManager.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  Uri _uri(String path, {Map<String, dynamic>? query}) {
    final qp = query?.map((k, v) => MapEntry(k, v.toString()));
    return Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/$path',
    ).replace(queryParameters: qp);
  }

  Future<http.Response> _send(
    Future<http.Response> Function() call, {
    bool retried = false,
  }) async {
    final response = await call().timeout(const Duration(seconds: 15));

    if (response.statusCode == 401 && !retried) {
      final refreshed = await SessionManager.refreshToken();

      if (refreshed) {
        return _send(call, retried: true);
      }

      await SessionManager.clearSession();
    }

    return response;
  }

  Future<http.Response> ADD(String body) {
    return _send(() async {
      return http.post(_uri(_doc), headers: await _headers(), body: body);
    });
  }

  Future<http.Response> FINDALL({Map<String, dynamic>? query}) {
    return _send(() async {
      return http.get(_uri(_doc, query: query), headers: await _headers());
    });
  }

  Future<http.Response> FINDONE(String id, {Map<String, dynamic>? query}) {
    return _send(() async {
      return http.get(
        _uri('$_doc/$id', query: query),
        headers: await _headers(),
      );
    });
  }

  Future<http.Response> UPDATEONE(String id, String body) {
    return _send(() async {
      return http.put(_uri('$_doc/$id'), headers: await _headers(), body: body);
    });
  }

  Future<http.Response> DELETEONE(String id) {
    return _send(() async {
      return http.delete(_uri('$_doc/$id'), headers: await _headers());
    });
  }
}
