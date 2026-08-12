import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentEntryService {
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
          'doctype': 'Payment Entry',
          'so_name': soName,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['message']?['data'];
        if (data == null) return [];

        final paymentEntry = data['Payment Entry'];
        if (paymentEntry == null) return [];

        final preview = paymentEntry['preview'];
        if (preview is List) {
          return preview
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        }
        return [];
      } else {
        print('PaymentEntry error: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('PaymentEntry exception: $e');
      return null;
    }
  }
}