import 'dart:convert';
import 'package:http/http.dart' as http;

class SalesInvoiceService {
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
          'Content-Type': 'application/json',       // ← tambah ini
          'Authorization': 'token $token',           // ← tambah ini
        },
        body: jsonEncode({
          'bcid': bcid,                              // ← sudah benar, string
          'doctype': 'Sales Invoice',
          'so_name': soName,
        }),
      );


      if (response.statusCode == 200) {
        final json     = jsonDecode(response.body);
        final data     = json['message']?['data'] as Map<String, dynamic>?;
        if (data == null) return [];

        final salesInvoice = data['Sales Invoice'] as Map<String, dynamic>?;
        if (salesInvoice == null) return [];

        final preview = salesInvoice['preview'];
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
