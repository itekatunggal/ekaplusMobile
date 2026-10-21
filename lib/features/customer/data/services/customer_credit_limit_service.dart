import 'dart:convert';
import 'dart:io';

import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/network/http_request_handler.dart';
import 'package:ekaplus_ekatunggal/core/network/network_exceptions.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/customer/data/models/customer_credit_policy.dart';
import 'package:http/http.dart' as http;

class CustomerCreditLimitService {
  CustomerCreditLimitService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _endpoint = Uri.parse(
    '${ApiConfig.baseUrl}/api/resource/branch_customer/method/'
    'get_customer_group_limit_info',
  );

  Future<CustomerCreditPolicy> fetch(
    String bcid, {
    int? branchCustomerId,
  }) async {
    final normalizedBcid = bcid.trim();
    if (normalizedBcid.isEmpty) {
      throw const FormatException('Kode BCID tidak tersedia');
    }

    Future<http.Response> request() async {
      final token = await SessionManager.getToken();
      return _client.post(
        _endpoint,
        headers: {
          ...ApiConfig.headers,
          if (token != null && token.isNotEmpty)
            HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode({'bcid': normalizedBcid}),
      );
    }

    final response = await HttpRequestHandler.send(
      request,
      timeout: ApiConfig.connectionTimeout,
      retryOnUnauthorized: () async {
        final refreshed = await SessionManager.refreshToken();
        if (!refreshed) throw const UnauthorizedException();
        return request();
      },
      defaultServerMessage: 'Gagal memuat informasi plafon kredit',
    );

    final policy = parseResponse(response.body);

    try {
      final ownerInfo = await _resolveLimitOwnerInfo(
        policy,
        branchCustomerId: branchCustomerId,
      );
      return policy.copyWith(
        limitOwnerName: ownerInfo.name,
        paymentTermDays: ownerInfo.paymentTermDays,
      );
    } catch (_) {
      // Informasi utama tetap dapat ditampilkan jika lookup nama gagal.
      return policy;
    }
  }

  Future<_LimitOwnerInfo> _resolveLimitOwnerInfo(
    CustomerCreditPolicy policy, {
    int? branchCustomerId,
  }) async {
    switch (policy.normalizedCreditLimitLevel) {
      case 'nbid':
        return _resourceInfo('national_brand', policy.nbid, 'nbid');
      case 'gpid':
        return _resourceInfo('group_parent', policy.gpid, 'gpid');
      case 'gcid':
        return _resourceInfo('group_customer', policy.gcid, 'gcid');
      case 'bcid':
        return _branchCustomerInfo(
          branchCustomerId: branchCustomerId,
          fallbackGcid: policy.gcid,
        );
      default:
        return const _LimitOwnerInfo();
    }
  }

  Future<_LimitOwnerInfo> _resourceInfo(
    String resource,
    int? id,
    String level,
  ) async {
    if (id == null || id <= 0) return const _LimitOwnerInfo();
    final data = await _fetchResourceData(resource, id);
    return _LimitOwnerInfo(
      name: resourceNameFromData(level, data),
      paymentTermDays: paymentTermFromData(data),
    );
  }

  Future<_LimitOwnerInfo> _branchCustomerInfo({
    required int? branchCustomerId,
    required int? fallbackGcid,
  }) async {
    var gcid = fallbackGcid;
    int? paymentTermDays;

    if (branchCustomerId != null && branchCustomerId > 0) {
      final branchData = await _fetchResourceData(
        'branch_customer',
        branchCustomerId,
        fields: const ['*', 'gcid.company_name'],
      );

      final nestedGcid = branchData['gcid'];
      paymentTermDays = paymentTermFromData(branchData);
      if (nestedGcid is Map) {
        final companyName = nestedGcid['company_name']?.toString().trim();
        if (companyName != null && companyName.isNotEmpty) {
          return _LimitOwnerInfo(
            name: companyName,
            paymentTermDays: paymentTermDays,
          );
        }
        gcid ??= _toInt(nestedGcid['id']);
      }
      gcid ??= _toInt(branchData['gcid_id'] ?? branchData['gcid']);
    }

    final groupCustomerInfo = await _resourceInfo(
      'group_customer',
      gcid,
      'gcid',
    );
    return _LimitOwnerInfo(
      name: groupCustomerInfo.name,
      paymentTermDays: paymentTermDays ?? groupCustomerInfo.paymentTermDays,
    );
  }

  Future<Map<String, dynamic>> _fetchResourceData(
    String resource,
    int id, {
    List<String> fields = const ['*'],
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/resource/$resource/$id')
        .replace(
          queryParameters: {
            'spec': jsonEncode({'fields': fields}),
          },
        );

    Future<http.Response> request() async {
      final token = await SessionManager.getToken();
      return _client.get(
        uri,
        headers: {
          ...ApiConfig.headers,
          if (token != null && token.isNotEmpty)
            HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );
    }

    final response = await HttpRequestHandler.send(
      request,
      timeout: ApiConfig.connectionTimeout,
      retryOnUnauthorized: () async {
        final refreshed = await SessionManager.refreshToken();
        if (!refreshed) throw const UnauthorizedException();
        return request();
      },
      defaultServerMessage: 'Gagal memuat sumber plafon kredit',
    );

    final decoded = jsonDecode(response.body);
    final data = decoded is Map<String, dynamic> ? decoded['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Data sumber plafon kredit tidak valid');
    }
    return data;
  }

  static String? resourceNameFromData(
    String creditLimitLevel,
    Map<String, dynamic> data,
  ) {
    final normalizedLevel = creditLimitLevel.trim().toLowerCase();
    final dynamic rawName = switch (normalizedLevel) {
      'nbid' => data['nb_name'],
      'gpid' => data['gp_name'],
      'gcid' => data['gc_name'] ?? data['company_name'],
      'bcid' =>
        data['gcid'] is Map ? (data['gcid'] as Map)['company_name'] : null,
      _ => null,
    };
    final name = rawName?.toString().trim();
    return name == null || name.isEmpty ? null : name;
  }

  static int? paymentTermFromData(Map<String, dynamic> data) {
    final active = data['payment_term_active'];
    final isActive =
        active == null ||
        active == true ||
        active == 1 ||
        active.toString().toLowerCase() == 'true';
    if (!isActive) return null;

    final days = _toInt(data['payment_term']);
    return days != null && days > 0 ? days : null;
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static CustomerCreditPolicy parseResponse(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format respons plafon kredit tidak valid');
    }

    final data = decoded['data'];
    final policy = data is Map<String, dynamic> ? data['policy'] : null;
    if (policy is! Map<String, dynamic>) {
      throw const FormatException('Data policy plafon kredit tidak tersedia');
    }

    return CustomerCreditPolicy.fromJson(policy);
  }
}

class _LimitOwnerInfo {
  const _LimitOwnerInfo({this.name, this.paymentTermDays});

  final String? name;
  final int? paymentTermDays;
}
