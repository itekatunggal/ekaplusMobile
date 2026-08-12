import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ekaplus_ekatunggal/features/invoice/data/models/invoice_detail_model.dart';

class InvoiceDetailService {
  Future<InvoiceDetail?> fetchDetail({
    required String baseUrl,
    required String token,
    required String invoiceName,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/resource/Sales Invoice/$invoiceName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'token $token',
        }
      );

      print("detail status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as Map<String, dynamic>? ?? {};
        return InvoiceDetail.fromJson(data);
      }
      return null;
    } catch (e) {
      print("fetchDetail error: $e");
      return null;
    }
  }
}