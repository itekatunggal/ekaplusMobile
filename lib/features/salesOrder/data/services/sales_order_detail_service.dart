import 'dart:convert';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_detail_model.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/sales_order_service.dart';
import 'package:http/http.dart' as http;

class SalesOrderDetailService {
  Future<SalesOrderDetail> fetchDetail({
    required String baseUrl,
    required String token,
    required String salesOrderName,
    String expectedCustomer = '',
    bool onlyPendingItems = false,
  }) async {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri =
        Uri.parse(
          '$root/api/method/ekaplus.utils.sales_order.get_sales_order_detail',
        ).replace(
          queryParameters: {
            'name': salesOrderName,
            'only_pending_items': onlyPendingItems ? '1' : '0',
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
          _message(response.statusCode),
          statusCode: response.statusCode,
        );
      }
      final decoded = jsonDecode(response.body);
      final message = decoded is Map ? decoded['message'] : null;
      final data = message is Map ? message['data'] : null;
      if (data is! Map) {
        throw const SalesOrderApiException(
          'Respons detail Sales Order tidak valid.',
        );
      }
      final mapped = Map<String, dynamic>.from(data);
      final responseCustomer = mapped['customer']?.toString().trim() ?? '';
      if (expectedCustomer.trim().isNotEmpty &&
          responseCustomer != expectedCustomer.trim()) {
        throw const SalesOrderApiException(
          'Sales Order tidak tersedia untuk customer aktif.',
          statusCode: 403,
        );
      }
      return SalesOrderDetail.fromJson(mapped);
    } on SalesOrderApiException {
      rethrow;
    } catch (_) {
      throw const SalesOrderApiException(
        'Detail Sales Order gagal dimuat. Periksa koneksi Anda.',
      );
    }
  }

  String _message(int status) => switch (status) {
    401 => 'Sesi berakhir. Silakan masuk kembali.',
    403 => 'Anda tidak diizinkan membuka Sales Order ini.',
    404 => 'Sales Order tidak ditemukan.',
    417 => 'Nomor Sales Order tidak valid.',
    _ => 'Detail Sales Order gagal dimuat (HTTP $status).',
  };
}
