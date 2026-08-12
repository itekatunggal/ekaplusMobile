import 'dart:convert';
import 'package:http/http.dart' as http;

class DocumentMeta {
  final String bcid;
  final String doctype;

  const DocumentMeta({
    required this.bcid,
    required this.doctype,
  });

  factory DocumentMeta.fromJson(Map<String, dynamic> json) {
    return DocumentMeta(
      bcid: json['bcid'] ?? '',
      doctype: json['doctype'] ?? '',
    );
  }
}

class DocumentMetaService {
  Future<DocumentMeta?> fetchMeta({
    required String baseUrl,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/api/method/ekaplus.api_dynamic_document_details.get_summary',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'token $token',
        },
      );

      print("meta status: ${response.statusCode}");
      print("meta body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] as Map<String, dynamic>? ?? {};
        return DocumentMeta.fromJson(message);
      }
      return null;
    } catch (e) {
      print("fetchMeta error: $e");
      return null;
    }
  }
}