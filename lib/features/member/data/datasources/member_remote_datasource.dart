// lib/features/member/data/datasources/member_local_datasource.dart
// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company_detail.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/customer_contact_option.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ekaplus_ekatunggal/features/member/data/models/member_registration_model.dart';
import 'package:http/http.dart' as http;

abstract class MemberRemoteDataSource {
  Future<List<MemberRegistration>> loadAllRegistrations({
    List<List<dynamic>>? filters,
  });
  Future<MemberRegistration> getRegistrationById(int memberId);
  Future<MemberRegistration> saveRegistration(
    Map<String, dynamic> registration, {
    required Map<String, File> files,
  });
  Future<void> updateRegistration(
    int memberId,
    MemberRegistrationModel registration,
  );
  Future<void> deleteRegistration(int memberId);
  Future<List<MemberRegistration>> getRegistrationsByUserId();
  Future<List<MemberRegistration>> getRegistrationsByStatus(String status);
  Future<List<MemberRegistration>> getApprovedGCIDsByUserId(int userId);
  Future<List<ActiveMemberCompany>> getActiveMemberCompaniesByUserId();
  Future<ActiveMemberCompanyDetail> getActiveMemberCompanyDetailByBcid(
    int bcidId, {
    ActiveMemberCompany? membershipSource,
  });
  Future<List<CustomerContactOption>> searchContacts(String query);
  Future<List<Map<String, dynamic>>> getCustomerPositions();
  Future<Map<String, dynamic>> createCustomerAddress(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> updateCustomerAddress(
    int addressId,
    Map<String, dynamic> payload,
  );
  Future<void> deleteCustomerAddress(int addressId);
  Future<Map<String, dynamic>> createContact(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> updateContact(int contactId, Map<String, dynamic> payload);
  Future<Map<String, dynamic>> createCustomerContact(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> updateCustomerContact(
    int customerContactId,
    Map<String, dynamic> payload,
  );
  Future<void> deleteCustomerContact(int customerContactId);
  Future<Map<String, dynamic>> createContactIdentity(Map<String, dynamic> payload);
  Future<Map<String, dynamic>> updateContactIdentity(
    int identityId,
    Map<String, dynamic> payload,
  );
  Future<void> deleteContactIdentity(int identityId);
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  final http.Client client;

  MemberRemoteDataSourceImpl({required this.client});

  String _normalizePhoneForDb(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return raw.trim();
    if (digits.startsWith('0')) return '62${digits.substring(1)}';
    if (digits.startsWith('62')) return digits;
    return digits;
  }

  String? _displayPhone(dynamic v) {
    final s = _safeNullableString(v)?.trim();
    if (s == null || s.isEmpty) return null;
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62') && digits.length > 2) {
      return '0${digits.substring(2)}';
    }
    if (digits.startsWith('0')) return digits;
    if (s.startsWith('+62') && digits.length > 2) return '0${digits.substring(2)}';
    return s;
  }

  Map<String, dynamic> _sanitizeCustomerRegisterPayload(
    Map<String, dynamic> raw,
  ) {
    const allowedKeys = <String>{
      'source',
      'ekaplus_user',
      'owner_name',
      'owner_full_name',
      'owner_phone',
      'owner_email',
      'owner_place_of_birth',
      'owner_date_of_birth',
      'branch_owner',
      'branch_owner_phone',
      'branch_owner_email',
      'branch_owner_place_of_birth',
      'branch_owner_date_of_birth',
      'company_type',
      'company_title',
      'company_name',
      'product_need',
      'nbid',
      'gpid',
      'gcid',
      'registration_mode',
      'request_type',
      'status',
      'branch_id',
      'company_address',
      'company_province',
      'company_city',
      'company_district',
      'company_postal_code',
      'same_as_company_address',
      'customer_shipping_address',
    };

    final payload = <String, dynamic>{};
    raw.forEach((key, value) {
      if (!allowedKeys.contains(key) || value == null) return;
      payload[key] = value;
    });
    if (payload['owner_phone'] != null) {
      payload['owner_phone'] = _normalizePhoneForDb(payload['owner_phone'].toString());
    }
    if (payload['branch_owner_phone'] != null) {
      payload['branch_owner_phone'] = _normalizePhoneForDb(
        payload['branch_owner_phone'].toString(),
      );
    }
    final shipping = payload['customer_shipping_address'];
    if (shipping is List) {
      payload['customer_shipping_address'] = shipping.map((e) {
        if (e is! Map) return e;
        final row = Map<String, dynamic>.from(e);
        if ((row['pic_phone'] ?? '').toString().trim().isNotEmpty) {
          row['pic_phone'] = _normalizePhoneForDb(row['pic_phone'].toString());
        }
        return row;
      }).toList();
    }

    return payload;
  }

  Exception _buildSaveException(dynamic responseBody, [int? statusCode]) {
    try {
      final decoded = jsonDecode(responseBody.toString());
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message']?.toString();
        final errors = decoded['errors'];
        if (message != null && message.isNotEmpty) {
          return Exception(
            'Failed to save registration${statusCode != null ? ' ($statusCode)' : ''}: $message${errors != null ? ' | $errors' : ''}',
          );
        }
      }
    } catch (_) {}

    return Exception(
      'Failed to save registration${statusCode != null ? ' ($statusCode)' : ''}: ${responseBody.toString()}',
    );
  }

  int _safeInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  int? _safeNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  String? _safeNullableString(dynamic v) {
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  DateTime? _safeNullableDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  bool _supportsDisabledFilter(String resource) {
    const resources = {
      'branch',
      'group_parent',
      'group_customer',
      'branch_customer',
      'customer_position',
    };
    return resources.contains(resource);
  }

  Future<List<Map<String, dynamic>>> _getResourceList(
    String resource, {
    required List<String> fields,
    List<List<dynamic>>? filters,
    List<List<dynamic>>? orderBy,
  }) async {
    final token = await SessionManager.getToken();
    final normalizedFilters = <List<dynamic>>[...?filters];
    if (_supportsDisabledFilter(resource) &&
        !normalizedFilters.any(
          (f) => f.isNotEmpty && f.first.toString() == 'disabled',
        )) {
      normalizedFilters.add(['disabled', '=', '0']);
    }
    final spec = <String, dynamic>{
      'fields': fields,
    };
    if (normalizedFilters.isNotEmpty) spec['filters'] = normalizedFilters;
    if (orderBy != null && orderBy.isNotEmpty) spec['order_by'] = orderBy;

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/api/resource/$resource'
      '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
    );

    final response = await client.get(
      uri,
      headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load $resource (${response.statusCode})');
    }

    final body = jsonDecode(response.body);
    final data = body['data'];
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map) {
      return [Map<String, dynamic>.from(data)];
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _getByIds(
    String resource,
    List<int> ids, {
    required List<String> fields,
    List<List<dynamic>>? extraFilters,
  }) async {
    final uniqueIds = ids.where((e) => e > 0).toSet().toList();
    if (uniqueIds.isEmpty) return [];

    final inFilters = <List<dynamic>>[
      ['id', 'in', uniqueIds],
      ...?extraFilters,
    ];

    try {
      return await _getResourceList(
        resource,
        fields: fields,
        filters: inFilters,
      );
    } catch (_) {
      final all = <Map<String, dynamic>>[];
      for (final id in uniqueIds) {
        final rows = await _getResourceList(
          resource,
          fields: fields,
          filters: [
            ['id', '=', '$id'],
            ...?extraFilters,
          ],
        );
        all.addAll(rows);
      }
      final byId = <int, Map<String, dynamic>>{};
      for (final row in all) {
        byId[_safeInt(row['id'])] = row;
      }
      return byId.values.toList();
    }
  }

  Future<List<Map<String, dynamic>>> _getByFieldValues(
    String resource,
    String field,
    List<int> values, {
    required List<String> fields,
    List<List<dynamic>>? extraFilters,
    List<List<dynamic>>? orderBy,
  }) async {
    final uniqueValues = values.where((e) => e > 0).toSet().toList();
    if (uniqueValues.isEmpty) return [];

    try {
      return await _getResourceList(
        resource,
        fields: fields,
        filters: [
          [field, 'in', uniqueValues],
          ...?extraFilters,
        ],
        orderBy: orderBy,
      );
    } catch (_) {
      final all = <Map<String, dynamic>>[];
      for (final value in uniqueValues) {
        final rows = await _getResourceList(
          resource,
          fields: fields,
          filters: [
            [field, '=', '$value'],
            ...?extraFilters,
          ],
          orderBy: orderBy,
        );
        all.addAll(rows);
      }
      return all;
    }
  }

  bool _isTruthy(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  Future<String> _authToken() async => (await SessionManager.getToken()) ?? '';

  Uri _resourceUri(String resource, [int? id]) => Uri.parse(
    id == null
        ? '${ApiConfig.baseUrl}/api/resource/$resource'
        : '${ApiConfig.baseUrl}/api/resource/$resource/$id',
  );

  Future<Map<String, dynamic>> _saveResource(
    String resource,
    Map<String, dynamic> payload, {
    int? id,
  }) async {
    final token = await _authToken();
    final response = id == null
        ? await client.post(
            _resourceUri(resource),
            headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
            body: jsonEncode(payload),
          )
        : await client.put(
            _resourceUri(resource, id),
            headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
            body: jsonEncode(payload),
          );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to save $resource (${response.statusCode}): ${response.body}');
    }
    final body = jsonDecode(response.body);
    final data = body is Map ? body['data'] : null;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<void> _deleteResource(String resource, int id) async {
    final token = await _authToken();
    final response = await client.delete(
      _resourceUri(resource, id),
      headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete $resource ($id): ${response.statusCode}');
    }
  }
  // ============================================
  Future<List<Map<String, dynamic>>> _loadRegistrationsFromAssets() async {
    try {
      final String body = await rootBundle.loadString(
        'assets/data/member_register.json',
      );

      final dynamic decoded = jsonDecode(body);

      // Handle both formats: {member_registrations: [...]} or [...]
      final List<dynamic> data = decoded is Map
          ? (decoded['member_registrations'] ?? [])
          : decoded;

      if (data.isEmpty) {
        throw '📭 No member registrations found in assets file';
      } else {
        throw ('📋 Registrations: ${data.map((r) => r['member_id']).toList()}');
      }
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // Save Registrations to Assets (Development)
  // ============================================
  Future<void> _saveRegistrationsToAssets(
    List<Map<String, dynamic>> registrations,
  ) async {
    if (kIsWeb) {
      return;
    }

    try {
      final projectPath = Directory.current.path;
      final assetsFile = File('$projectPath/assets/data/member_register.json');

      // Create folder if not exists
      final assetsDir = Directory('$projectPath/assets/data');
      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
      }

      // Save with pretty print
      final jsonData = {
        'member_registrations': registrations,
        'last_updated': DateTime.now().toIso8601String(),
        'total_registrations': registrations.length,
      };

      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(jsonData);
      await assetsFile.writeAsString(prettyJson);
    } catch (e) {
      // Don't throw - this is development feature
    }
  }

  // ============================================
  // 1. Load All Registrations
  // ============================================
  @override
  Future<List<MemberRegistration>> loadAllRegistrations({
    List<List<dynamic>>? filters,
  }) async {
    try {
      final token = await SessionManager.getToken();
      final spec = <String, dynamic>{
        "fields": [
          "*",
          "branch_id.id",
          "branch_id.branch_name",
          "branch_id.city",
        ],
        "order_by": [
          ["created_at", "desc"],
        ],
      };

      if (filters != null && filters.isNotEmpty) {
        spec["filters"] = filters as dynamic;
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/resource/customer_register'
        '?spec=${Uri.encodeComponent(jsonEncode(spec))}',
      );

      final response = await client.get(
        uri,
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil data tipe');
      }

      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'] ?? [];

      List<MemberRegistration> result = MemberRegistrationModel.fromJsonList(
        data,
      );

      return result;
    } catch (e) {
      throw Exception('Failed to get data: $e');
    }
  }

  // ============================================
  // 2. Get Registration by ID
  // ============================================
  @override
  Future<MemberRegistration> getRegistrationById(int id) async {
    try {
      final token = await SessionManager.getToken();
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/resource/customer_register/$id',
      );

      final response = await client.get(
        uri,
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Gagal mengambil detail registrasi');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Format response detail tidak valid');
      }

      return MemberRegistrationModel.fromJson(data);
    } catch (e) {
      throw "❌ Error getting registration by ID: $e";
    }
  }

  @override
  Future<MemberRegistration> saveRegistration(
    Map<String, dynamic> registration, {
    required Map<String, File> files,
  }) async {
    try {
      final token = await SessionManager.getToken();
      final payload = _sanitizeCustomerRegisterPayload(registration);
      final editingId = registration['id'] is int
          ? registration['id'] as int
          : int.tryParse('${registration['id'] ?? ''}');
      final requestPayload = <String, dynamic>{...payload};
      if (editingId != null) {
        requestPayload['id'] = editingId;
      }

      final uri = editingId != null
          ? Uri.parse('${ApiConfig.baseUrl}/api/resource/customer_register/$editingId')
          : Uri.parse('${ApiConfig.baseUrl}/api/resource/customer_register');
      late final int statusCode;
      late final String responseBody;

      if (files.isEmpty) {
        final response = editingId != null
            ? await client.put(
                uri,
                headers: {
                  ...ApiConfig.headers,
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode(requestPayload),
              )
            : await client.post(
                uri,
                headers: {
                  ...ApiConfig.headers,
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode(requestPayload),
              );
        if ((response.statusCode == 307 || response.statusCode == 308) &&
            response.headers['location'] != null) {
          final redirectedUri = uri.resolve(response.headers['location']!);
          final redirectedResponse = editingId != null
              ? await client.put(
                  redirectedUri,
                  headers: {
                    ...ApiConfig.headers,
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(requestPayload),
                )
              : await client.post(
                  redirectedUri,
                  headers: {
                    ...ApiConfig.headers,
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(requestPayload),
                );
          statusCode = redirectedResponse.statusCode;
          responseBody = redirectedResponse.body;
        } else {
          statusCode = response.statusCode;
          responseBody = response.body;
        }
      } else {
        final request = http.MultipartRequest(
          editingId != null ? 'PUT' : 'POST',
          uri,
        );
        request.headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

        requestPayload.forEach((key, value) {
          if (value is List || value is Map) {
            request.fields[key] = jsonEncode(value);
          } else {
            request.fields[key] = value.toString();
          }
        });

        for (final entry in files.entries) {
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value.path),
          );
        }

        final response = await request.send();
        statusCode = response.statusCode;
        responseBody = await response.stream.bytesToString();
      }

      if (statusCode < 200 || statusCode >= 300) {
        throw _buildSaveException(responseBody, statusCode);
      }

      final Map<String, dynamic> json =
          jsonDecode(responseBody) as Map<String, dynamic>;

      final data = json['data'];
      final resultId = editingId ??
          (data is Map<String, dynamic>
              ? (data['id'] is int
                    ? data['id'] as int
                    : int.tryParse('${data['id'] ?? ''}') ?? 0)
              : 0);
      if (resultId == 0) {
        throw Exception('Response save registration tidak berisi id');
      }
      MemberRegistration result = await getRegistrationById(resultId);

      return result;
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to save registration: $e');
    }
  }

  @override
  Future<void> updateRegistration(
    int memberId,
    MemberRegistrationModel registration,
  ) async {
    try {
      // Load existing registrations
      final registrationsData = await _loadRegistrationsFromAssets();

      // Find registration by member_id
      final index = registrationsData.indexWhere(
        (r) => r['member_id'] == memberId,
      );

      if (index == -1) {
        throw Exception('Registration not found: $memberId');
      }

      // Update registration
      // registrationsData[index] = registration.toJson();

      // Save back to assets
      await _saveRegistrationsToAssets(registrationsData);
    } catch (e) {
      throw Exception('Failed to update registration: $e');
    }
  }

  // ============================================
  // 5. Delete Registration
  // ============================================
  @override
  Future<void> deleteRegistration(int memberId) async {
    try {
      final token = await SessionManager.getToken();
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/resource/customer_register/$memberId',
      );
      final response = await client.delete(
        uri,
        headers: {...ApiConfig.headers, 'Authorization': 'Bearer $token'},
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Failed to delete registration ($memberId): '
          '${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to delete registration: $e');
    }
  }

  // ============================================
  // 6. Get Registrations by User ID
  // ============================================
  @override
  Future<List<MemberRegistration>> getRegistrationsByUserId() async {
    try {
      final userData = await SessionManager.getCurrentUser();

      final user = UserModel.fromLocalJson(userData!);
      final rows = await loadAllRegistrations(
        filters: [
          ["created_by", "=", "${user.id}"],
        ],
      );

      final merged = rows.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return merged;
    } catch (e) {
      throw '❌ Error getting registrations by user ID: $e';
    }
  }

  // ============================================
  // 7. Get Registrations by Status
  // ============================================
  @override
  Future<List<MemberRegistration>> getRegistrationsByStatus(
    String status,
  ) async {
    try {
      // final registrations = await loadAllRegistrations();
      // return registrations.where((reg) => reg.status == status).toList();
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // 8. Get Approved GCIDs by User ID
  // ============================================
  @override
  Future<List<MemberRegistration>> getApprovedGCIDsByUserId(int userId) async {
    try {
      final registrations = await loadAllRegistrations();
      return registrations.where((reg) {
        return reg == userId && reg == 'GCID' && reg == 'approved';
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ActiveMemberCompany>> getActiveMemberCompaniesByUserId() async {
    final userData = await SessionManager.getCurrentUser();
    final user = UserModel.fromLocalJson(userData!);

    Future<List<Map<String, dynamic>>> loadMemberOfByRefType(String refType) =>
        _getResourceList(
          'member_of',
          fields: ['*'],
          filters: [
            ['user_id', '=', '${user.id}'],
            ['ref_type', '=', refType],
          ],
        );

    List<Map<String, dynamic>> memberOfRows;
    try {
      memberOfRows = await loadMemberOfByRefType('gpid');
    } catch (_) {
      // Compatibility for legacy API field name.
      memberOfRows = await _getResourceList(
        'member_of',
        fields: ['*'],
        filters: [
          ['user', '=', '${user.id}'],
          ['ref_type', '=', 'gpid'],
        ],
      );
    }

    List<Map<String, dynamic>> legacyBcidMembershipRows = const [];
    if (memberOfRows.isEmpty) {
      try {
        legacyBcidMembershipRows = await _getResourceList(
          'member_of',
          fields: ['*'],
          filters: [
            ['user_id', '=', '${user.id}'],
            ['ref_type', '=', 'bcid'],
          ],
        );
      } catch (_) {
        legacyBcidMembershipRows = await _getResourceList(
          'member_of',
          fields: ['*'],
          filters: [
            ['user', '=', '${user.id}'],
            ['ref_type', '=', 'bcid'],
          ],
        );
      }
    }

    if (memberOfRows.isEmpty && legacyBcidMembershipRows.isEmpty) return [];

    final gpidMemberById = <int, Map<String, dynamic>>{
      for (final row in memberOfRows)
        if (_safeInt(row['ref_id']) > 0) _safeInt(row['ref_id']): row,
    };

    final gpids = gpidMemberById.keys.toList();
    final groupCustomerRows = await _getByFieldValues(
      'group_customer',
      'gpid',
      gpids,
      fields: ['*'],
    );
    final groupCustomerById = {
      for (final row in groupCustomerRows) _safeInt(row['id']): row,
    };

    final gcids = groupCustomerRows
        .map((e) => _safeInt(e['id']))
        .where((e) => e > 0)
        .toList();

    final branchCustomerRowsFromGp = await _getByFieldValues(
      'branch_customer',
      'gcid',
      gcids,
      fields: ['*', 'branch.name', 'branch.branch_name', 'branch.city'],
    );

    final legacyBranchCustomerIds = legacyBcidMembershipRows
        .map((e) => _safeInt(e['ref_id']))
        .where((e) => e > 0)
        .toList();
    final branchCustomerRowsFromLegacy = await _getByIds(
      'branch_customer',
      legacyBranchCustomerIds,
      fields: ['*', 'branch.name', 'branch.branch_name', 'branch.city'],
    );

    final branchCustomerRows = <Map<String, dynamic>>[
      ...branchCustomerRowsFromGp,
      ...branchCustomerRowsFromLegacy,
    ];
    final branchCustomerById = <int, Map<String, dynamic>>{};
    for (final row in branchCustomerRows) {
      final id = _safeInt(row['id']);
      if (id > 0) branchCustomerById[id] = row;
    }

    final allGpids = groupCustomerRows
        .map((e) => _safeInt(e['gpid']))
        .followedBy(gpids)
        .where((e) => e > 0)
        .toList();
    final groupParentRows = await _getByIds(
      'group_parent',
      allGpids,
      fields: ['*'],
    );
    final groupParentById = {
      for (final row in groupParentRows) _safeInt(row['id']): row,
    };

    final nbids = groupParentRows
        .map((e) => _safeInt(e['nbid']))
        .where((e) => e > 0)
        .toList();
    final nationalBrandRows = await _getByIds(
      'national_brand',
      nbids,
      fields: ['*'],
    );
    final nationalBrandById = {
      for (final row in nationalBrandRows) _safeInt(row['id']): row,
    };

    final allBcidIds = branchCustomerById.keys.toList();
    List<Map<String, dynamic>> addressRows = [];
    if (allBcidIds.isNotEmpty) {
      try {
        addressRows = await _getByFieldValues(
          'customer_address',
          'parent_id',
          allBcidIds,
          fields: ['*'],
          extraFilters: [
            ['parent_type', '=', 'branch_customer'],
          ],
          orderBy: [
            ['is_default', 'desc'],
            ['idx', 'asc'],
            ['id', 'asc'],
          ],
        );
      } catch (_) {
        // Fallback for alternative schema.
        addressRows = await _getByFieldValues(
          'customer_address',
          'bcid',
          allBcidIds,
          fields: ['*'],
          orderBy: [
            ['is_default', 'desc'],
            ['idx_row', 'asc'],
            ['id', 'asc'],
          ],
        );
      }
    }
    final defaultAddressByBcid = <int, Map<String, dynamic>>{};
    for (final row in addressRows) {
      final parentId = _safeInt(row['parent_id'] ?? row['bcid'] ?? row['bcid_id']);
      if (parentId <= 0) continue;
      final existing = defaultAddressByBcid[parentId];
      if (existing == null ||
          (!_isTruthy(existing['is_default']) && _isTruthy(row['is_default']))) {
        defaultAddressByBcid[parentId] = row;
      }
    }

    final result = <ActiveMemberCompany>[];
    final addedBcid = <int>{};

    for (final bc in branchCustomerById.values) {
      final bcid = _safeInt(bc['id']);
      if (bcid <= 0 || !addedBcid.add(bcid)) continue;
      final gcid = _safeInt(bc['gcid']);
      final gc = groupCustomerById[gcid];
      final gpid = gc == null ? 0 : _safeInt(gc['gpid']);
      final gp = groupParentById[gpid];
      final nbid = gp == null ? 0 : _safeInt(gp['nbid']);
      final nb = nationalBrandById[nbid];

      final mo = gpidMemberById[gpid] ??
          legacyBcidMembershipRows.firstWhere(
            (e) => _safeInt(e['ref_id']) == bcid,
            orElse: () => const <String, dynamic>{},
          );

      final branchObj = bc['branch'];
      final branchName = branchObj is Map
          ? (_safeNullableString(branchObj['branch_name']) ??
              _safeNullableString(branchObj['name']))
          : (_safeNullableString(bc['branch.branch_name']) ??
              _safeNullableString(bc['branch.name']));
      final branchCity = branchObj is Map
          ? _safeNullableString(branchObj['city'])
          : _safeNullableString(bc['branch.city']);
      final defaultAddress = defaultAddressByBcid[bcid];

      result.add(
        ActiveMemberCompany(
          memberOfId: _safeInt(mo['id']),
          refType: (mo['ref_type'] ?? 'gpid').toString(),
          refId: _safeInt(mo['ref_id']),
          userId: _safeInt(mo['user_id'] ?? mo['user']),
          memberOfStatus: _safeNullableString(mo['status']),
          memberIsOwner: _isTruthy(mo['is_owner']),
          memberIsSharing: _isTruthy(mo['is_sharing']),
          shareFromUserId: _safeNullableInt(mo['share_from']),
          branchCustomerId: _safeNullableInt(bc['id']),
          branchCustomerCode: _safeNullableString(bc['name']),
          branchId: _safeNullableInt(bc['branch_id'] ?? bc['branch']),
          branchName: branchName,
          branchCity: branchCity,
          branchOwnerName: _safeNullableString(bc['branch_owner']),
          branchOwnerPhone: _displayPhone(bc['branch_owner_phone']),
          branchOwnerEmail: _safeNullableString(bc['branch_owner_email']),
          branchOwnerPlaceOfBirth: _safeNullableString(bc['branch_owner_place_of_birth']),
          branchOwnerDateOfBirth: _safeNullableString(bc['branch_owner_date_of_birth']),
          gcidId: gc == null ? null : _safeNullableInt(gc['id']),
          gcName: _safeNullableString(gc == null ? null : gc['gc_name']),
          gpidId: gp == null ? null : _safeNullableInt(gp['id']),
          gpCode: _safeNullableString(gp == null ? null : gp['name']),
          gpName: _safeNullableString(gp == null ? null : gp['gp_name']),
          nbidId: nbid > 0 ? nbid : null,
          nbName: _safeNullableString(nb == null ? null : (nb['nb_name'] ?? nb['name'])),
          customerRegisterId: null,
          customerRegisterStatus: null,
          customerOwnerName: _safeNullableString(gc == null ? null : gc['owner_full_name']),
          customerOwnerEmail: _safeNullableString(gc == null ? null : gc['owner_email']),
          customerOwnerPhone: _displayPhone(gc == null ? null : gc['owner_phone']),
          customerOwnerPlaceOfBirth: _safeNullableString(
            gc == null ? null : gc['owner_place_of_birth'],
          ),
          customerOwnerDateOfBirth: _safeNullableString(gc == null ? null : gc['owner_date_of_birth']),
          customerCompanyName: _safeNullableString(gc == null ? null : gc['company_name']),
          customerCompanyType: _safeNullableString(gc == null ? null : gc['company_type']),
          customerCompanyTitle: _safeNullableString(gc == null ? null : gc['company_title']),
          customerProductNeed: _safeNullableString(bc['product_need']),
          customerCompanyAddress: _safeNullableString(defaultAddress == null ? null : defaultAddress['address']),
          customerCompanyProvince: _safeNullableString(defaultAddress == null ? null : defaultAddress['province']),
          customerCompanyCity: _safeNullableString(defaultAddress == null ? null : defaultAddress['city']),
          customerCompanyDistrict: _safeNullableString(defaultAddress == null ? null : defaultAddress['district']),
          customerCompanyPostalCode: _safeNullableString(
            defaultAddress == null ? null : defaultAddress['postal_code'],
          ),
          createdAt: _safeNullableDate(mo['created_at']),
        ),
      );
    }

    result.sort((a, b) {
      final gcCmp = (a.gcName ?? '').toLowerCase().compareTo(
        (b.gcName ?? '').toLowerCase(),
      );
      if (gcCmp != 0) return gcCmp;
      return (a.branchCity ?? '').toLowerCase().compareTo(
        (b.branchCity ?? '').toLowerCase(),
      );
    });

    return result;
  }

  ActiveCompanyAddress _mapAddressRow(Map<String, dynamic> row) {
    return ActiveCompanyAddress(
      id: _safeInt(row['id']),
      type: _safeNullableString(row['type']),
      label: _safeNullableString(row['label']),
      address: _safeNullableString(row['address']),
      city: _safeNullableString(row['city']),
      district: _safeNullableString(row['district']),
      province: _safeNullableString(row['province']),
      postalCode: _safeNullableString(row['postal_code']),
      isDefault: _isTruthy(row['is_default']),
      picContactId: _safeNullableInt(row['pic_contact_id']),
      picName: _safeNullableString(row['pic_name']),
      picPhone: _displayPhone(row['pic_phone']),
      idxRow: _safeNullableInt(row['idx_row']),
    );
  }

  Future<List<Map<String, dynamic>>> _getByBcidWithFallback(
    String resource,
    int bcidId, {
    required List<String> fields,
    List<List<dynamic>>? orderBy,
  }) async {
    try {
      return await _getByFieldValues(
        resource,
        'bcid',
        [bcidId],
        fields: fields,
        orderBy: orderBy,
      );
    } catch (_) {
      try {
        return await _getByFieldValues(
          resource,
          'bcid_id',
          [bcidId],
          fields: fields,
          orderBy: orderBy,
        );
      } catch (_) {
        return const [];
      }
    }
  }

  @override
  Future<ActiveMemberCompanyDetail> getActiveMemberCompanyDetailByBcid(
    int bcidId, {
    ActiveMemberCompany? membershipSource,
  }) async {
    final bcRows = await _getByIds(
      'branch_customer',
      [bcidId],
      fields: ['*', 'branch.name', 'branch.branch_name', 'branch.city'],
    );
    if (bcRows.isEmpty) {
      throw Exception('BCID tidak ditemukan');
    }
    final bc = bcRows.first;
    final gcid = _safeInt(bc['gcid']);
    final gcRows = await _getByIds('group_customer', [gcid], fields: ['*']);
    final gc = gcRows.isEmpty ? null : gcRows.first;
    final gpid = gc == null ? 0 : _safeInt(gc['gpid']);
    final gpRows = await _getByIds('group_parent', [gpid], fields: ['*']);
    final gp = gpRows.isEmpty ? null : gpRows.first;
    final nbid = gp == null ? 0 : _safeInt(gp['nbid']);
    final nbRows = await _getByIds('national_brand', [nbid], fields: ['*']);
    final nb = nbRows.isEmpty ? null : nbRows.first;

    final addressRows = await _getByBcidWithFallback(
      'customer_address',
      bcidId,
      fields: ['*'],
      orderBy: [
        ['is_default', 'desc'],
        ['idx_row', 'asc'],
        ['id', 'asc'],
      ],
    );

    final customerContactRows = await _getByBcidWithFallback(
      'customer_contact',
      bcidId,
      fields: ['*'],
      orderBy: [
        ['is_primary', 'desc'],
        ['idx_row', 'asc'],
        ['id', 'asc'],
      ],
    );
    final contactIds = customerContactRows
        .map((e) => _safeInt(e['contact_id']))
        .where((e) => e > 0)
        .toList();
    final positionIds = customerContactRows
        .map((e) => _safeInt(e['position_id']))
        .where((e) => e > 0)
        .toList();
    final contacts = contactIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _getByIds('contact', contactIds, fields: ['*']);
    final positions = positionIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _getByIds(
            'customer_position',
            positionIds,
            fields: ['*'],
          );
    final identities = contactIds.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _getByFieldValues(
            'contact_identities',
            'contact_id',
            contactIds,
            fields: ['*'],
            orderBy: [
              ['id', 'asc'],
            ],
          );

    final contactById = {for (final row in contacts) _safeInt(row['id']): row};
    final positionById = {
      for (final row in positions) _safeInt(row['id']): row,
    };
    final identityByContact = <int, List<ActiveCompanyContactIdentity>>{};
    for (final row in identities) {
      final cid = _safeInt(row['contact_id']);
      if (cid <= 0) continue;
      identityByContact.putIfAbsent(cid, () => []).add(
        ActiveCompanyContactIdentity(
          id: _safeInt(row['id']),
          contactId: cid,
          channel: _safeNullableString(row['channel']),
          handle: (((row['channel'] ?? '').toString() == 'phone') ||
                  ((row['channel'] ?? '').toString() == 'whatsapp'))
              ? _displayPhone(row['handle'])
              : _safeNullableString(row['handle']),
          externalId: _safeNullableString(row['external_id']),
          isVerified: _isTruthy(row['is_verified']),
        ),
      );
    }

    final detailContacts = customerContactRows.map((row) {
      final contactId = _safeInt(row['contact_id']);
      final contact = contactById[contactId];
      final position = positionById[_safeInt(row['position_id'])];
      return ActiveCompanyContact(
        customerContactId: _safeInt(row['id']),
        contactId: contactId,
        name: _safeNullableString(contact?['name']),
        fullName: _safeNullableString(contact?['full_name']),
        phone: _displayPhone(contact?['phone']),
        email: _safeNullableString(contact?['email']),
        positionId: _safeNullableInt(row['position_id']),
        positionName: _safeNullableString(
          position?['position_name'] ?? row['position_name'],
        ),
        title: _safeNullableString(row['title']),
        isPrimary: _isTruthy(row['is_primary']),
        idxRow: _safeNullableInt(row['idx_row']),
        identities: identityByContact[contactId] ?? const [],
      );
    }).toList();

    final branchObj = bc['branch'];
    final branchName = branchObj is Map
        ? (_safeNullableString(branchObj['branch_name']) ??
            _safeNullableString(branchObj['name']))
        : (_safeNullableString(bc['branch.branch_name']) ??
            _safeNullableString(bc['branch.name']));
    final branchCity = branchObj is Map
        ? _safeNullableString(branchObj['city'])
        : _safeNullableString(bc['branch.city']);

    return ActiveMemberCompanyDetail(
      bcidId: bcidId,
      bcidCode: _safeNullableString(bc['name']),
      branchCustomerName: _safeNullableString(bc['name']),
      gcidId: _safeNullableInt(gc?['id']),
      gcName: _safeNullableString(gc?['gc_name']),
      gpidId: _safeNullableInt(gp?['id']),
      gpCode: _safeNullableString(gp?['name']),
      gpName: _safeNullableString(gp?['gp_name']),
      nbidId: nbid > 0 ? nbid : null,
      nbName: _safeNullableString(nb?['name'] ?? nb?['nb_name']),
      branchId: _safeNullableInt(bc['branch_id'] ?? bc['branch']),
      branchName: branchName,
      branchCity: branchCity,
      ownerFullName: _safeNullableString(gc?['owner_full_name']),
      ownerPhone: _displayPhone(gc?['owner_phone']),
      ownerEmail: _safeNullableString(gc?['owner_email']),
      ownerPlaceOfBirth: _safeNullableString(gc?['owner_place_of_birth']),
      ownerDateOfBirth: _safeNullableString(gc?['owner_date_of_birth']),
      companyType: _safeNullableString(gc?['company_type']),
      companyTitle: _safeNullableString(gc?['company_title']),
      companyName: _safeNullableString(gc?['company_name']),
      productNeed: _safeNullableString(bc['product_need']),
      memberIsOwner: membershipSource?.memberIsOwner ?? false,
      memberIsSharing: membershipSource?.memberIsSharing ?? false,
      addresses: addressRows.map(_mapAddressRow).toList(),
      contacts: detailContacts,
    );
  }

  @override
  Future<List<CustomerContactOption>> searchContacts(String query) async {
    final q = query.trim();
    if (q.length < 2) return const [];
    List<Map<String, dynamic>> rows = [];
    for (final field in const ['full_name', 'name', 'phone', 'email']) {
      try {
        final partial = await _getResourceList(
          'contact',
          fields: ['*'],
          filters: [
            [field, 'like', '%$q%'],
          ],
        );
        rows.addAll(partial);
      } catch (_) {
        // Try next field/filter style; API compatibility varies.
      }
    }
    if (rows.isEmpty) {
      rows = await _getResourceList(
        'contact',
        fields: ['*'],
      );
      rows = rows.where((row) {
        final hay = [
          row['name'],
          row['full_name'],
          row['phone'],
          row['email'],
        ].map((e) => (e ?? '').toString().toLowerCase()).join(' ');
        return hay.contains(q.toLowerCase());
      }).toList();
    }
    final byId = <int, CustomerContactOption>{};
    for (final row in rows) {
      final id = _safeInt(row['id']);
      if (id <= 0) continue;
      byId[id] = CustomerContactOption(
        id: id,
        name: _safeNullableString(row['name']),
        fullName: _safeNullableString(row['full_name']),
        phone: _displayPhone(row['phone']),
        email: _safeNullableString(row['email']),
      );
    }
    return byId.values.toList()
      ..sort((a, b) => a.displayLabel.toLowerCase().compareTo(b.displayLabel.toLowerCase()));
  }

  @override
  Future<List<Map<String, dynamic>>> getCustomerPositions() async {
    return _getResourceList(
      'customer_position',
      fields: ['*'],
      filters: [
        ['disabled', '=', '0'],
      ],
      orderBy: [
        ['position_name', 'asc'],
      ],
    );
  }

  Map<String, dynamic> _sanitizeAddressPayload(Map<String, dynamic> raw) {
    const allowed = {
      'bcid',
      'type',
      'label',
      'address',
      'city',
      'district',
      'province',
      'postal_code',
      'is_default',
      'pic_contact_id',
      'pic_name',
      'pic_phone',
      'idx_row',
    };
    final result = {
      for (final entry in raw.entries)
        if (allowed.contains(entry.key) && entry.value != null) entry.key: entry.value,
    };
    if (result['pic_phone'] != null &&
        result['pic_phone'].toString().trim().isNotEmpty) {
      result['pic_phone'] = _normalizePhoneForDb(result['pic_phone'].toString());
    }
    return result;
  }

  Map<String, dynamic> _sanitizeContactPayload(Map<String, dynamic> raw) {
    const allowed = {'name', 'full_name', 'phone', 'email'};
    final result = {
      for (final entry in raw.entries)
        if (allowed.contains(entry.key) && entry.value != null) entry.key: entry.value,
    };
    if (result['phone'] != null && result['phone'].toString().trim().isNotEmpty) {
      result['phone'] = _normalizePhoneForDb(result['phone'].toString());
    }
    return result;
  }

  Map<String, dynamic> _sanitizeCustomerContactPayload(Map<String, dynamic> raw) {
    const allowed = {
      'bcid',
      'contact_id',
      'position_id',
      'title',
      'is_primary',
      'idx_row',
    };
    return {
      for (final entry in raw.entries)
        if (allowed.contains(entry.key) && entry.value != null) entry.key: entry.value,
    };
  }

  Map<String, dynamic> _sanitizeIdentityPayload(Map<String, dynamic> raw) {
    const allowed = {
      'contact_id',
      'channel',
      'handle',
      'external_id',
      'is_verified',
    };
    final result = {
      for (final entry in raw.entries)
        if (allowed.contains(entry.key) && entry.value != null) entry.key: entry.value,
    };
    final channel = (result['channel'] ?? '').toString().trim();
    if ((channel == 'phone' || channel == 'whatsapp') &&
        result['handle'] != null &&
        result['handle'].toString().trim().isNotEmpty) {
      result['handle'] = _normalizePhoneForDb(result['handle'].toString());
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> createCustomerAddress(Map<String, dynamic> payload) {
    return _saveResource('customer_address', _sanitizeAddressPayload(payload));
  }

  @override
  Future<Map<String, dynamic>> updateCustomerAddress(
    int addressId,
    Map<String, dynamic> payload,
  ) {
    return _saveResource('customer_address', _sanitizeAddressPayload(payload), id: addressId);
  }

  @override
  Future<void> deleteCustomerAddress(int addressId) {
    return _deleteResource('customer_address', addressId);
  }

  @override
  Future<Map<String, dynamic>> createContact(Map<String, dynamic> payload) {
    return _saveResource('contact', _sanitizeContactPayload(payload));
  }

  @override
  Future<Map<String, dynamic>> updateContact(int contactId, Map<String, dynamic> payload) {
    return _saveResource('contact', _sanitizeContactPayload(payload), id: contactId);
  }

  @override
  Future<Map<String, dynamic>> createCustomerContact(Map<String, dynamic> payload) {
    return _saveResource(
      'customer_contact',
      _sanitizeCustomerContactPayload(payload),
    );
  }

  @override
  Future<Map<String, dynamic>> updateCustomerContact(
    int customerContactId,
    Map<String, dynamic> payload,
  ) {
    return _saveResource(
      'customer_contact',
      _sanitizeCustomerContactPayload(payload),
      id: customerContactId,
    );
  }

  @override
  Future<void> deleteCustomerContact(int customerContactId) {
    return _deleteResource('customer_contact', customerContactId);
  }

  @override
  Future<Map<String, dynamic>> createContactIdentity(Map<String, dynamic> payload) {
    return _saveResource(
      'contact_identities',
      _sanitizeIdentityPayload(payload),
    );
  }

  @override
  Future<Map<String, dynamic>> updateContactIdentity(
    int identityId,
    Map<String, dynamic> payload,
  ) {
    return _saveResource(
      'contact_identities',
      _sanitizeIdentityPayload(payload),
      id: identityId,
    );
  }

  @override
  Future<void> deleteContactIdentity(int identityId) {
    return _deleteResource('contact_identities', identityId);
  }
}
