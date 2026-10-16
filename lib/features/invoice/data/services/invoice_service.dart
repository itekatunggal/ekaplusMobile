import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ekaplus_ekatunggal/features/invoice/data/models/invoice_model.dart';

enum InvoiceFetchStatus { success, unauthorized, error }

class InvoiceFetchResult {
  final InvoiceFetchStatus status;
  final List<Invoice> items;
  final String? message;

  const InvoiceFetchResult({
    required this.status,
    this.items = const [],
    this.message,
  });
}

class InvoiceService {
  Future<InvoiceFetchResult> fetchInvoices({
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


      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final message =
            responseBody['message'] as Map<String, dynamic>? ?? {};
        final success = message['success'] == true;

        if (!success) {
          return const InvoiceFetchResult(
            status: InvoiceFetchStatus.error,
            message: 'Gagal memuat data dari server.',
          );
        }

        final data = message['data'] as Map<String, dynamic>? ?? {};
        final doctypeData = data[doctype] as Map<String, dynamic>? ?? {};
        final preview = doctypeData['preview'] as List? ?? [];

        final list = preview
            .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
            .toList();

        return InvoiceFetchResult(
          status: InvoiceFetchStatus.success,
          items: list,
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return const InvoiceFetchResult(
          status: InvoiceFetchStatus.unauthorized,
          message: 'Token tidak valid atau tidak memiliki akses.',
        );
      } else {
        return InvoiceFetchResult(
          status: InvoiceFetchStatus.error,
          message: 'Gagal memuat data (${response.statusCode})',
        );
      }
    } catch (e) {
      return InvoiceFetchResult(
        status: InvoiceFetchStatus.error,
        message: 'Terjadi kesalahan: $e',
      );
    }
  }
}


// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:ekaplus_ekatunggal/features/invoice/data/models/invoice_model.dart';

// enum InvoiceFetchStatus { success, unauthorized, error }

// class InvoiceFetchResult {
//   final InvoiceFetchStatus status;
//   final List<Invoice> items;
//   final String? message;

//   const InvoiceFetchResult({
//     required this.status,
//     this.items = const [],
//     this.message,
//   });
// }

// class InvoiceService {
//   Future<InvoiceFetchResult> fetchInvoices({
//     required String baseUrl,
//     required String token,
//     required String bcid,
//     required String doctype,
//     int page = 1,
//   }) async {
//     try {
//       final uri = Uri.parse('$baseUrl/api/resource/Sales Invoice').replace(
//         queryParameters: {
//           // 'fields': '["name","customer","customer_name","due_date","status","grand_total"]',
//           // 'filters': '[["$doctype","customer","=","$bcid"]]',
//           // 'limit': '100',
//           'limit_start': '${(page - 1) * 100}',
//           // 'order_by': 'due_date desc',
//         },
//       );

//       print("📡 URL: $uri");

//       final response = await http.get(  
//         uri,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'token $token',
//         },
//       );

//       print("📡 STATUS CODE: ${response.statusCode}");
//       print("📡 BODY: ${response.body}");

//       if (response.statusCode == 200) {
//         final responseBody = jsonDecode(response.body);
//         final data = responseBody['data'] as List? ?? [];  // ✅ key 'data', bukan 'message'

//         final list = data
//             .map((e) => Invoice.fromJson(e as Map<String, dynamic>))
//             .toList();

//         return InvoiceFetchResult(
//           status: InvoiceFetchStatus.success,
//           items: list,
//         );
//       } else if (response.statusCode == 401 || response.statusCode == 403) {
//         return const InvoiceFetchResult(
//           status: InvoiceFetchStatus.unauthorized,
//           message: 'Token tidak valid atau tidak memiliki akses.',
//         );
//       } else {
//         return InvoiceFetchResult(
//           status: InvoiceFetchStatus.error,
//           message: 'Gagal memuat data (${response.statusCode})',
//         );
//       }
//     } catch (e) {
//       return InvoiceFetchResult(
//         status: InvoiceFetchStatus.error,
//         message: 'Terjadi kesalahan: $e',
//       );
//     }
//   }
// }
