import 'dart:convert';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_model.dart';
import 'package:http/http.dart' as http;

class SalesOrderApiException implements Exception {
  const SalesOrderApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class SalesOrderService {
  static const _pageSize = 20;
  Future<SalesOrderPageData> fetchSalesOrders({
    required String baseUrl,
    required String token,
    int page = 1,
    String? status,
    String search = '',
  }) async {
    final message = await _get(
      baseUrl: baseUrl,
      token: token,
      method: 'get_sales_orders',
      query: {
        'docstatus': '1',
        'page': '$page',
        'page_size': '$_pageSize',
        'sort': 'newest',
        if (status != null && status.isNotEmpty) 'status': status,
        if (search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final pagination = _map(message['pagination']);
    final rows = message['data'] as List? ?? const [];
    return SalesOrderPageData(
      items: rows
          .whereType<Map>()
          .map((row) => SalesOrder.fromJson(Map<String, dynamic>.from(row)))
          .toList(growable: false),
      page: _int(pagination['page'], fallback: page),
      hasNext: _boolean(pagination['has_next']),
      total: _int(pagination['total']),
    );
  }

  Future<PendingItemsPageData> fetchPendingItems({
    required String baseUrl,
    required String token,
    required String bcid,
    int page = 1,
    bool onlyOverdue = false,
    String search = '',
  }) async {
    final message = await _getItemsToBeDelivered(
      baseUrl: baseUrl,
      token: token,
      bcid: bcid,
      page: page,
    );
    final pagination = _map(message['pagination']);
    final rows = message['data'] as List? ?? const [];
    final mappedRows = rows
        .whereType<Map>()
        .map(
          (row) =>
              PendingSalesOrderItem.fromJson(Map<String, dynamic>.from(row)),
        )
        .where((item) {
          final query = search.trim().toLowerCase();
          final matchesSearch =
              query.isEmpty ||
              item.itemCode.toLowerCase().contains(query) ||
              item.itemName.toLowerCase().contains(query);
          return matchesSearch && (!onlyOverdue || item.isOverdue);
        })
        .toList(growable: false);
    final totalRows = _int(pagination['count'], fallback: mappedRows.length);
    final uniqueOrders = mappedRows
        .map((item) => item.salesOrder)
        .toSet()
        .length;
    return PendingItemsPageData(
      items: mappedRows,
      page: page,
      hasNext: _boolean(pagination['has_next']),
      total: totalRows,
      summary: PendingItemsSummary(
        totalSalesOrders: uniqueOrders,
        totalItemRows: totalRows,
        overdueRows: mappedRows.where((item) => item.isOverdue).length,
      ),
    );
  }

  Future<Map<String, dynamic>> _getItemsToBeDelivered({
    required String baseUrl,
    required String token,
    required String bcid,
    required int page,
  }) async {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final limitStart = (page - 1) * _pageSize;
    final uri =
        Uri.parse(
          '$root/api/method/ekaplus.api.sales_order.get_items_to_be_delivered',
        ).replace(
          queryParameters: {
            'bcid': bcid,
            'limit_start': '$limitStart',
            'limit_page_length': '$_pageSize',
          },
        );
    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'token $token',
        },
      );
      if (response.statusCode != 200) {
        throw SalesOrderApiException(
          _statusMessage(response.statusCode),
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      final message = decoded is Map ? decoded['message'] : null;
      if (message is! Map) {
        throw const SalesOrderApiException('Respons server tidak valid.');
      }
      return Map<String, dynamic>.from(message);
    } on SalesOrderApiException {
      rethrow;
    } catch (_) {
      throw const SalesOrderApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      );
    }
  }

  Future<Map<String, dynamic>> _get({
    required String baseUrl,
    required String token,
    required String method,
    required Map<String, String> query,
  }) async {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse(
      '$root/api/method/ekaplus.utils.sales_order.$method',
    ).replace(queryParameters: query);
    try {
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'token $token',
        },
      );
      if (response.statusCode != 200) {
        throw SalesOrderApiException(
          _statusMessage(response.statusCode),
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      final message = decoded is Map ? decoded['message'] : null;
      if (message is! Map) {
        throw const SalesOrderApiException('Respons server tidak valid.');
      }
      return Map<String, dynamic>.from(message);
    } on SalesOrderApiException {
      rethrow;
    } catch (_) {
      throw const SalesOrderApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      );
    }
  }

  String _statusMessage(int code) => switch (code) {
    401 => 'Sesi berakhir. Silakan masuk kembali.',
    403 => 'Akses Sales Order tidak diizinkan untuk akun ini.',
    404 => 'Data Sales Order tidak ditemukan.',
    417 => 'Parameter permintaan Sales Order tidak valid.',
    _ => 'Sales Order gagal dimuat (HTTP $code).',
  };
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
int _int(Object? value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _boolean(Object? value) =>
    value == true || value == 1 || value?.toString().toLowerCase() == 'true';
