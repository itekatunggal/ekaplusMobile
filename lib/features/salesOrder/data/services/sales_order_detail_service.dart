import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_detail_model.dart';

class SalesOrderDetailService {
  Future<SalesOrderDetail?> fetchDetail({
    required String baseUrl,
    required String token,
    required String salesOrderName,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/resource/Sales Order/$salesOrderName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'token $token',
        },
      );


      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as Map<String, dynamic>? ?? {};
        return SalesOrderDetail.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
