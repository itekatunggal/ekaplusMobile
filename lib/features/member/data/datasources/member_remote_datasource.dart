// lib/features/member/data/datasources/member_local_datasource.dart
// ignore_for_file: unrelated_type_equality_checks

import 'dart:convert';
import 'dart:io';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
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
}

class MemberRemoteDataSourceImpl implements MemberRemoteDataSource {
  final http.Client client;

  MemberRemoteDataSourceImpl({required this.client});

  Map<String, dynamic> _sanitizeCustomerRegisterPayload(
    Map<String, dynamic> raw,
  ) {
    const allowedKeys = <String>{
      'source',
      'owner_full_name',
      'owner_phone',
      'owner_email',
      'owner_place_of_birth',
      'owner_date_of_birth',
      'company_type',
      'company_title',
      'company_name',
      'product_need',
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

  Future<List<Map<String, dynamic>>> _getResourceList(
    String resource, {
    required List<String> fields,
    List<List<dynamic>>? filters,
    List<List<dynamic>>? orderBy,
  }) async {
    final token = await SessionManager.getToken();
    final spec = <String, dynamic>{
      'fields': fields,
    };
    if (filters != null && filters.isNotEmpty) spec['filters'] = filters;
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
                body: jsonEncode(payload),
              )
            : await client.post(
          uri,
          headers: {
            ...ApiConfig.headers,
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
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
                  body: jsonEncode(payload),
                )
              : await client.post(
            redirectedUri,
            headers: {
              ...ApiConfig.headers,
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          );
          statusCode = redirectedResponse.statusCode;
          responseBody = redirectedResponse.body;
        } else {
          statusCode = response.statusCode;
          responseBody = response.body;
        }
      } else {
        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

        payload.forEach((key, value) {
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
      // Load existing registrations
      final registrationsData = await _loadRegistrationsFromAssets();

      // Remove registration
      registrationsData.removeWhere((r) => r['member_id'] == memberId);

      // Save back to assets
      await _saveRegistrationsToAssets(registrationsData);
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
      final ownerRegistrations = await loadAllRegistrations(
        filters: [
          ["owner", "=", "${user.id}"],
        ],
      );

      final ekaplusUserRegistrations = await loadAllRegistrations(
        filters: [
          ["ekaplus_user", "=", "${user.id}"],
        ],
      );

      final mergedById = <int, MemberRegistration>{};
      for (final reg in ownerRegistrations) {
        mergedById[reg.id] = reg;
      }
      for (final reg in ekaplusUserRegistrations) {
        mergedById[reg.id] = reg;
      }

      final merged = mergedById.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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

    final memberOfRows = await _getResourceList(
      'member_of',
      fields: ['*'],
      filters: [
        ['user', '=', '${user.id}'],
        ['ref_type', '=', 'bcid'],
      ],
    );

    if (memberOfRows.isEmpty) return [];

    final branchCustomerIds = memberOfRows
        .map((e) => _safeInt(e['ref_id']))
        .where((e) => e > 0)
        .toList();

    final branchCustomerRows = await _getByIds(
      'branch_customer',
      branchCustomerIds,
      fields: ['*', 'branch.branch_name', 'branch.city'],
    );
    final branchCustomerById = {
      for (final row in branchCustomerRows) _safeInt(row['id']): row,
    };

    final gcids = branchCustomerRows
        .map((e) => _safeInt(e['gcid']))
        .where((e) => e > 0)
        .toList();
    final groupCustomerRows = await _getByIds(
      'group_customer',
      gcids,
      fields: ['*'],
    );
    final groupCustomerById = {
      for (final row in groupCustomerRows) _safeInt(row['id']): row,
    };

    final gpids = groupCustomerRows
        .map((e) => _safeInt(e['gpid']))
        .where((e) => e > 0)
        .toList();
    final groupParentRows = await _getByIds(
      'group_parent',
      gpids,
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

    final customerRegisterRows = await _getByFieldValues(
      'customer_register',
      'bcid',
      branchCustomerIds,
      fields: [
        '*',
        'branch_id.id',
        'branch_id.branch_name',
        'branch_id.city',
      ],
      extraFilters: [
        ['ekaplus_user', '=', '${user.id}'],
      ],
      orderBy: [
        ['updated_at', 'desc'],
        ['created_at', 'desc'],
      ],
    );
    if (customerRegisterRows.isEmpty) {
      customerRegisterRows.addAll(
        await _getByFieldValues(
          'customer_register',
          'bcid',
          branchCustomerIds,
          fields: [
            '*',
            'branch_id.id',
            'branch_id.branch_name',
            'branch_id.city',
          ],
          extraFilters: [
            ['owner', '=', '${user.id}'],
          ],
          orderBy: [
            ['updated_at', 'desc'],
            ['created_at', 'desc'],
          ],
        ),
      );
    }
    final customerRegisterByBcid = <int, Map<String, dynamic>>{};
    for (final row in customerRegisterRows) {
      final bcid = _safeInt(row['bcid']);
      if (bcid <= 0) continue;
      customerRegisterByBcid.putIfAbsent(bcid, () => row);
    }

    final result = <ActiveMemberCompany>[];
    for (final mo in memberOfRows) {
      final refId = _safeInt(mo['ref_id']);
      final bc = branchCustomerById[refId];
      final gcid = bc == null ? 0 : _safeInt(bc['gcid']);
      final gc = groupCustomerById[gcid];
      final gpid = gc == null ? 0 : _safeInt(gc['gpid']);
      final gp = groupParentById[gpid];
      final nbid = gp == null ? 0 : _safeInt(gp['nbid']);
      final nb = nationalBrandById[nbid];
      final cr = customerRegisterByBcid[refId];

      final branchObj = bc?['branch'];
      final branchName = branchObj is Map
          ? _safeNullableString(branchObj['branch_name'])
          : _safeNullableString(bc?['branch.branch_name']);
      final branchCity = branchObj is Map
          ? _safeNullableString(branchObj['city'])
          : _safeNullableString(bc?['branch.city']);

      result.add(
        ActiveMemberCompany(
          memberOfId: _safeInt(mo['id']),
          refType: (mo['ref_type'] ?? 'bcid').toString(),
          refId: refId,
          userId: _safeInt(mo['user']),
          memberOfStatus: _safeNullableString(mo['status']),
          branchCustomerId: bc == null ? null : _safeNullableInt(bc['id']),
          branchCustomerCode: _safeNullableString(bc?['name']),
          branchId: bc == null ? null : _safeNullableInt(bc['branch_id']),
          branchName: branchName,
          branchCity: branchCity,
          gcidId: gc == null ? null : _safeNullableInt(gc['id']),
          gcName: _safeNullableString(gc?['gc_name']),
          gpidId: gp == null ? null : _safeNullableInt(gp['id']),
          gpCode: _safeNullableString(gp?['name']),
          gpName: _safeNullableString(gp?['gp_name']),
          nbidId: nbid > 0 ? nbid : null,
          nbName: _safeNullableString(nb?['nb_name']),
          customerRegisterId: cr == null ? null : _safeNullableInt(cr['id']),
          customerRegisterStatus: _safeNullableString(cr?['status']),
          customerOwnerName: _safeNullableString(cr?['owner_full_name']),
          customerOwnerEmail: _safeNullableString(cr?['owner_email']),
          customerOwnerPhone: _safeNullableString(cr?['owner_phone']),
          customerCompanyName: _safeNullableString(cr?['company_name']),
          customerCompanyType: _safeNullableString(cr?['company_type']),
          customerCompanyTitle: _safeNullableString(cr?['company_title']),
          customerProductNeed: _safeNullableString(cr?['product_need']),
          customerCompanyAddress: _safeNullableString(cr?['company_address']),
          customerCompanyProvince: _safeNullableString(cr?['company_province']),
          customerCompanyCity: _safeNullableString(cr?['company_city']),
          customerCompanyDistrict: _safeNullableString(cr?['company_district']),
          customerCompanyPostalCode: _safeNullableString(
            cr?['company_postal_code'],
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
}
