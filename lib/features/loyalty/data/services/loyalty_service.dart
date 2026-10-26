import 'dart:convert';
import 'dart:io';

import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/network/http_request_handler.dart';
import 'package:ekaplus_ekatunggal/core/network/network_exceptions.dart';
import 'package:ekaplus_ekatunggal/core/network/query_spec_builder.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/loyalty/domain/entities/loyalty_models.dart';
import 'package:http/http.dart' as http;

class LoyaltyService {
  LoyaltyService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<LoyaltyLedger?> getActiveLedger(int gpid) async {
    final rows = await _getResource(
      'loyalty_point_ledger',
      QuerySpecBuilder()
          .fields(const [
            'calculation_id',
            'calculation_name',
            'earned_point',
            'period_name',
            'ready',
            'expired',
            'valid_from',
            'valid_to',
          ])
          .where('gpid', '=', gpid)
          .where('ready', '=', 1)
          .where('expired', '=', 0)
          .orderBy('calculation_id', direction: 'desc')
          .limit(1)
          .build(),
      'Gagal memuat saldo Ekapoint',
    );
    return rows.isEmpty ? null : LoyaltyLedger.fromJson(rows.first);
  }

  Future<List<LoyaltyEarningDetail>> getCalculationDetails(
    int calculationId,
  ) async {
    final rows = await _getResource(
      'loyalty_calculation_detail',
      QuerySpecBuilder()
          .fields(const [
            'account',
            'omzet_snapshot',
            'standard_divider_snapshot',
            'awarded_point',
            'calculation_id',
          ])
          .where('calculation_id', '=', calculationId)
          .where('omzet_snapshot', '>', 0)
          .orderBy('awarded_point', direction: 'desc')
          .orderBy('omzet_snapshot', direction: 'desc')
          .limit(0)
          .build(),
      'Gagal memuat rincian poin',
    );
    return rows.map(LoyaltyEarningDetail.fromJson).toList(growable: false);
  }

  Future<List<LoyaltyPurchaseSource>> getCalculationSources({
    required int calculationId,
    required String account,
    int page = 1,
    int limit = 20,
  }) async {
    final rows = await _getResource(
      'loyalty_calculation_source',
      QuerySpecBuilder()
          .fields(const [
            'account',
            'omzet',
            'branch_id',
            'bc_refs',
            'customer_count',
            'calculation_id',
          ])
          .where('calculation_id', '=', calculationId)
          .where('account', '=', account)
          .where('omzet', '>', 0)
          .orderBy('omzet', direction: 'desc')
          .page(page)
          .limit(limit)
          .build(),
      'Gagal memuat sumber pembelian',
    );
    final sources = rows.map(LoyaltyPurchaseSource.fromJson).toList();
    final bcReferences = sources
        .expand((source) => _splitBcReferences(source.bcReference))
        .toSet()
        .toList();
    final branchIds = sources
        .map((source) => source.branchId)
        .whereType<int>()
        .toSet()
        .toList();
    final customerNames = bcReferences.isEmpty
        ? const <String, String>{}
        : await _getCustomerGroupNames(bcReferences);
    final branchCities = branchIds.isEmpty
        ? const <int, String>{}
        : await _getBranchCities(branchIds);
    return sources
        .map((source) {
          final resolvedCustomerNames = _splitBcReferences(source.bcReference)
              .map((reference) => customerNames[reference])
              .whereType<String>()
              .toSet()
              .join(', ');
          return source.copyWith(
            customerGroupName: resolvedCustomerNames.isEmpty
                ? null
                : resolvedCustomerNames,
            branchCity: branchCities[source.branchId],
          );
        })
        .toList(growable: false);
  }

  Future<Map<String, String>> getCategoryIcons() async {
    final rows = await _getResource(
      'ekatalog_category',
      QuerySpecBuilder()
          .fields(const ['category_name', 'icon'])
          .limit(0)
          .build(),
      'Gagal memuat ikon kategori',
    );

    return {
      for (final row in rows)
        if ((row['category_name']?.toString().trim() ?? '').isNotEmpty &&
            (row['icon']?.toString().trim() ?? '').isNotEmpty)
          row['category_name'].toString().trim(): row['icon'].toString().trim(),
    };
  }

  List<String> _splitBcReferences(String value) => value
      .split(RegExp(r'[,;\n]+'))
      .map((reference) => reference.trim())
      .where((reference) => reference.isNotEmpty && reference != '-')
      .toList(growable: false);

  Future<Map<String, String>> _getCustomerGroupNames(
    List<String> bcReferences,
  ) async {
    try {
      final rows = await _getResource(
        'branch_customer',
        QuerySpecBuilder()
            .fields(const ['id', 'name', 'gcid', 'gcid.gc_name'])
            .where('name', 'in', bcReferences)
            .limit(0)
            .build(),
        'Gagal memuat nama customer',
      );

      final groupNames = <String, String>{};
      final unresolvedGcidByReference = <String, int>{};
      for (final row in rows) {
        final reference = row['name']?.toString().trim() ?? '';
        if (reference.isEmpty) continue;

        final gcid = row['gcid'];
        final nestedName = gcid is Map
            ? gcid['gc_name']?.toString().trim() ?? ''
            : '';
        final expandedName =
            row['gcid.gc_name']?.toString().trim() ??
            row['gc_name']?.toString().trim() ??
            '';
        final name = nestedName.isNotEmpty ? nestedName : expandedName;
        if (name.isNotEmpty) {
          groupNames[reference] = name;
          continue;
        }

        final gcidId = _toInt(
          gcid is Map ? gcid['id'] ?? gcid['value'] : row['gcid_id'] ?? gcid,
        );
        if (gcidId != null) unresolvedGcidByReference[reference] = gcidId;
      }

      if (unresolvedGcidByReference.isNotEmpty) {
        final groupRows = await _getResource(
          'group_customer',
          QuerySpecBuilder()
              .fields(const ['id', 'gc_name'])
              .where(
                'id',
                'in',
                unresolvedGcidByReference.values.toSet().toList(),
              )
              .limit(0)
              .build(),
          'Gagal memuat nama group customer',
        );
        final namesById = {
          for (final row in groupRows)
            if (_toInt(row['id']) != null &&
                (row['gc_name']?.toString().trim() ?? '').isNotEmpty)
              _toInt(row['id'])!: row['gc_name'].toString().trim(),
        };
        for (final entry in unresolvedGcidByReference.entries) {
          final name = namesById[entry.value];
          if (name != null) groupNames[entry.key] = name;
        }
      }

      return groupNames;
    } catch (_) {
      return const {};
    }
  }

  Future<Map<int, String>> _getBranchCities(List<int> branchIds) async {
    try {
      final rows = await _getResource(
        'branch',
        QuerySpecBuilder()
            .fields(const ['id', 'city'])
            .where('id', 'in', branchIds)
            .limit(0)
            .build(),
        'Gagal memuat nama cabang',
      );

      return {
        for (final row in rows)
          if (_toInt(row['id']) != null &&
              (row['city']?.toString().trim() ?? '').isNotEmpty)
            _toInt(row['id'])!: row['city'].toString().trim(),
      };
    } catch (_) {
      return const {};
    }
  }

  int? _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

  Future<LoyaltyBalance> getBalance(String bcid) async {
    final data = await _post('loyalty_redemption/method/get_balance', {
      'bcid': bcid,
    }, 'Gagal memuat saldo poin');
    return LoyaltyBalance.fromJson(data);
  }

  Future<LoyaltyEarnings> getEarnings(String bcid) async {
    final data = await _post(
      'loyalty_calculation/method/get_customer_point_detail',
      {'bcid': bcid},
      'Gagal memuat perolehan poin',
    );
    return LoyaltyEarnings.fromJson(data);
  }

  Future<List<LoyaltyReward>> getRewards(String bcid) async {
    final data = await _post('loyalty_reward/method/get_customer_rewards', {
      'bcid': bcid,
    }, 'Gagal memuat reward');
    return _listFrom(data, const [
      'rows',
      'rewards',
      'items',
    ]).map(LoyaltyReward.fromJson).toList(growable: false);
  }

  Future<List<LoyaltyRedemption>> getHistory(
    String bcid, {
    int limit = 20,
    int? offset,
  }) async {
    final data = await _post('loyalty_redemption/method/get_history', {
      'bcid': bcid,
      'limit': limit,
      if (offset != null) 'offset': offset,
    }, 'Gagal memuat aktivitas poin');
    return _listFrom(data, const [
      'rows',
      'history',
      'items',
    ]).map(LoyaltyRedemption.fromJson).toList(growable: false);
  }

  Future<LoyaltyRedemptionStatus> redeem({
    required String bcid,
    required String rewardId,
    required int quantity,
    required String idempotencyKey,
  }) async {
    final data = await _post('loyalty_redemption/method/redeem', {
      'reward': rewardId,
      'bcid': bcid,
      'quantity': quantity,
      'idempotency_key': idempotencyKey,
    }, 'Penukaran poin belum berhasil');
    return parseRedemptionStatus(data['status'] ?? data['redemption_status']);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> payload,
    String fallbackMessage,
  ) async {
    final normalizedBcid = payload['bcid']?.toString().trim() ?? '';
    if (normalizedBcid.isEmpty) {
      throw const FormatException('Customer aktif tidak tersedia');
    }
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/resource/$path');

    Future<http.Response> request() async {
      final token = await SessionManager.getToken();
      return _client.post(
        uri,
        headers: {
          ...ApiConfig.headers,
          if (token != null && token.isNotEmpty)
            HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
    }

    final response = await HttpRequestHandler.send(
      request,
      timeout: ApiConfig.connectionTimeout,
      retryOnUnauthorized: () async {
        if (!await SessionManager.refreshToken()) {
          throw const UnauthorizedException();
        }
        return request();
      },
      defaultServerMessage: fallbackMessage,
    );
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Format respons loyalty tidak valid');
    }
    final root = Map<String, dynamic>.from(decoded);
    final envelope = root['message'] is Map
        ? Map<String, dynamic>.from(root['message'] as Map)
        : root;
    final data = envelope['data'] ?? root['data'] ?? envelope;
    if (data is! Map) {
      throw const FormatException('Data loyalty tidak tersedia');
    }
    return Map<String, dynamic>.from(data);
  }

  List<Map<String, dynamic>> _listFrom(
    Map<String, dynamic> data,
    List<String> keys,
  ) {
    dynamic value;
    for (final key in keys) {
      if (data[key] is List) {
        value = data[key];
        break;
      }
    }
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _getResource(
    String resource,
    Map<String, dynamic> spec,
    String fallbackMessage,
  ) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/$resource',
    ).replace(queryParameters: {'spec': jsonEncode(spec)});

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
        if (!await SessionManager.refreshToken()) {
          throw const UnauthorizedException();
        }
        return request();
      },
      defaultServerMessage: fallbackMessage,
    );
    final decoded = jsonDecode(response.body);
    if (decoded is! Map || decoded['data'] is! List) {
      throw const FormatException('Format data loyalty tidak valid');
    }
    return (decoded['data'] as List)
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList(growable: false);
  }
}
