import 'dart:convert';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_item_detail_model.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/sales_order_service.dart';
import 'package:http/http.dart' as http;

class SalesOrderItemDetailService {
  Future<SalesOrderItemDetail> fetch({
    required String baseUrl,
    required String token,
    required String salesOrder,
    required String salesOrderItem,
  }) async {
    final root = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri =
        Uri.parse(
          '$root/api/method/ekaplus.utils.sales_order.get_sales_order_item_detail',
        ).replace(
          queryParameters: {
            'sales_order': salesOrder,
            'sales_order_item': salesOrderItem,
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
          'Respons detail produk tidak valid.',
        );
      }
      return SalesOrderItemDetail.fromJson(Map<String, dynamic>.from(data));
    } on SalesOrderApiException {
      rethrow;
    } catch (_) {
      throw const SalesOrderApiException(
        'Detail produk gagal dimuat. Periksa koneksi Anda.',
      );
    }
  }

  String _message(int status) => switch (status) {
    401 => 'Sesi berakhir. Silakan masuk kembali.',
    403 => 'Riwayat produk tidak diizinkan untuk akun ini.',
    404 => 'Produk Sales Order tidak ditemukan.',
    417 => 'Referensi produk Sales Order tidak valid.',
    _ => 'Detail produk gagal dimuat (HTTP $status).',
  };
}
