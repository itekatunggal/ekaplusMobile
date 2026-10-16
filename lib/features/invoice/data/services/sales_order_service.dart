import 'dart:convert';
import 'package:http/http.dart' as http;

class SalesOrderService {
  Future<List<Map<String, dynamic>>?> fetchBySOName({
    required String baseUrl,
    required String token,
    required String bcid,
    required String soName,
    required String invoiceName,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/method/ekaplus.api_dynamic_document_details.get_summary/$invoiceName',
      );

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bcid': bcid,
          'doctype': 'Sales Order',
          'so_name': soName,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['message']?['data'];
        if (data == null) return [];

        final salesOrder = data['Sales Order']; // ← fix di sini
        if (salesOrder == null) return [];

        final preview = salesOrder['preview'];
        if (preview is List) {
          return preview
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
        return [];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
