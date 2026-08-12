import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/branch_credential_service.dart';
import 'package:ekaplus_ekatunggal/features/member/presentation/cubit/active_company_cubit.dart';

class TransaksiSummaryService {
  Future<Map<String, int>> fetchInvoiceSummary({
    required String baseUrl,
    required String token,
    required String bcid,
  }) async {
    return _fetch(baseUrl: baseUrl, token: token, bcid: bcid, doctype: 'Sales Invoice');
  }

  Future<Map<String, int>> fetchSalesOrderSummary({
    required String baseUrl,
    required String token,
    required String bcid,
  }) async {
    return _fetch(baseUrl: baseUrl, token: token, bcid: bcid, doctype: 'Sales Order');
  }

  Future<Map<String, int>> _fetch({
    required String baseUrl,
    required String token,
    required String bcid,
    required String doctype,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/method/ekaplus.api_dynamic_document_details.get_limit_detail');

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'token $token',
        },
        body: jsonEncode({'bcid': [bcid], 'doctype': doctype}),
      );

      if (res.statusCode != 200) return _empty();

      final body    = jsonDecode(res.body);
      final message = body['message'] as Map<String, dynamic>?;
      final success = message?['success'] as bool? ?? false;
      if (!success) return _empty();

      final data     = message!['data'] as Map<String, dynamic>?;
      final customer = data?[bcid] as Map<String, dynamic>?;
      if (customer == null) return _empty();

      final ps = customer['per_status'] as Map<String, dynamic>? ?? {};
      return {
        'paid'    : ps['Paid']?['total_count']    as int? ?? 0,
        'unpaid'  : ps['Unpaid']?['total_count']  as int? ?? 0,
        'overdue' : ps['Overdue']?['total_count'] as int? ?? 0,
      };
    } catch (e) {
      debugPrint('TransaksiSummaryService error [$doctype]: $e');
      return _empty();
    }
  }

  Map<String, int> _empty() => {'paid': 0, 'unpaid': 0, 'overdue': 0};
}