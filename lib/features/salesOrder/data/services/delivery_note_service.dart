import 'dart:convert';
import 'package:http/http.dart' as http;

class DeliveryNoteService {
  Future<List<Map<String, dynamic>>?> fetchBySOName({
    required String baseUrl,
    required String token,
    required String bcid,
    required String invoiceName, 
    String? soName,              
    String? refName,             
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/api/method/ekaplus.api_dynamic_document_details.get_summary/$invoiceName',
      );

      // Tentukan filter key yang dipakai
      final Map<String, dynamic> body = {
        'bcid':    bcid,
        'doctype': 'Delivery Note',
      };

      if (soName != null)  body['so_name']  = soName;   
      if (refName != null) body['ref_name'] = refName;  

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'token $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['message']?['data'];
        if (data == null) return [];

        final deliveryNote = data['Delivery Note'];
        if (deliveryNote == null) return [];

        final preview = deliveryNote['preview'];
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
