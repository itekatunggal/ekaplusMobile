import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_model.dart';

enum SalesOrderFetchStatus { success, unauthorized, error }

class SalesOrderFetchResult {
  final SalesOrderFetchStatus status;
  final List<SalesOrder> items;
  final String? message;

  const SalesOrderFetchResult({
    required this.status,
    this.items = const [],
    this.message,
  });
}

class SalesOrderService {
  Future<SalesOrderFetchResult> fetchSalesOrder({
    required String baseUrl,
    required String token,
    required String bcid,
    required String doctype,
    int page = 1,
  }) async {
    try {
      final body = jsonEncode({
        'bcid': bcid,
        'doctype': doctype,
        'page': page,
      });

      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/method/ekaplus.api_dynamic_document_details.get_summary',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'token $token',
        },
        body: body,
      );

      print("STATUS CODE: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final message =
            responseBody['message'] as Map<String, dynamic>? ?? {};
        final success = message['success'] == true;

        if (!success) {
          return const SalesOrderFetchResult(
            status: SalesOrderFetchStatus.error,
            message: 'Gagal memuat data dari server.',
          );
        }

        final data = message['data'] as Map<String, dynamic>? ?? {};
        final doctypeData = data[doctype] as Map<String, dynamic>? ?? {};
        final preview = doctypeData['preview'] as List? ?? [];

        final list = preview
            .map((e) => SalesOrder.fromJson(e as Map<String, dynamic>))
            .toList();

        return SalesOrderFetchResult(
          status: SalesOrderFetchStatus.success,
          items: list,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return const SalesOrderFetchResult(
          status: SalesOrderFetchStatus.unauthorized,
          message: 'Token tidak valid atau tidak memiliki akses.',
        );
      } else {
        return SalesOrderFetchResult(
          status: SalesOrderFetchStatus.error,
          message: 'Gagal memuat data (${response.statusCode})',
        );
      }
    } catch (e) {
      return SalesOrderFetchResult(
        status: SalesOrderFetchStatus.error,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }
}