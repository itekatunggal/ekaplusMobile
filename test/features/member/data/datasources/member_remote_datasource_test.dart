import 'dart:convert';
import 'dart:io';

import 'package:ekaplus_ekatunggal/features/member/data/datasources/member_remote_datasource.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('member_test_');
    Hive.init(hiveDirectory.path);
    await Hive.openBox('auth_user_box');
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test(
    'keeps every compact memberofuser BCID when a batch lookup is partial',
    () async {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 'test-token'});
      await Hive.box('auth_user_box').put('current_user', {'id': 21});

      var retriedBcid19 = false;
      final client = _TestClient((request) async {
        if (request.method == 'POST' &&
            request.url.path.endsWith('/member_of/method/memberofuser')) {
          return _jsonResponse({
            'data': [
              {'id': 19, 'name': 'ALSHINDO FOAM HI - BOGOR'},
              {'id': 39, 'name': 'ANUGERAH KARYA ASLINDO PT - BOGOR'},
              {'id': 505, 'name': 'ANUGERAH KARYA ASLINDO PT - PEKANBARU'},
              {'id': 617, 'name': 'ANUGERAH KARYA ASLINDO PT - PALEMBANG'},
              {
                'id': 859,
                'name': 'ANUGERAH MULTIPLIKASI INDONESIA PT - PALEMBANG',
              },
            ],
          });
        }

        final resource = request.url.pathSegments.length >= 3
            ? request.url.pathSegments[2]
            : '';
        final spec = _requestSpec(request.url);
        final filters = (spec['filters'] as List?) ?? const [];

        if (resource == 'member_of') return _jsonResponse({'data': []});

        if (resource == 'branch_customer') {
          final idFilter = filters.whereType<List>().firstWhere(
            (filter) => filter.isNotEmpty && filter.first == 'id',
            orElse: () => const [],
          );
          if (idFilter.length >= 3 && idFilter[1] == 'in') {
            final ids = (idFilter[2] as List).cast<num>();
            return _jsonResponse({
              'data': ids
                  .map((id) => id.toInt())
                  .where((id) => id != 19)
                  .map(_branchCustomer)
                  .toList(),
            });
          }
          if (idFilter.length >= 3 && idFilter[1] == '=' && idFilter[2] == 19) {
            retriedBcid19 = true;
            return _jsonResponse({
              'data': [_branchCustomer(19, nestedGcid: true)],
            });
          }
        }

        if (resource == 'group_customer') {
          final ids = _idsFromFilters(filters);
          return _jsonResponse({
            'data': ids
                .map(
                  (id) => {
                    'id': id,
                    'gpid': null,
                    'disabled': 0,
                    'gc_name': id == 19 ? 'ALSHINDO FOAM HI' : 'COMPANY $id',
                    'company_name': id == 19
                        ? 'ALSHINDO FOAM HI'
                        : 'COMPANY $id',
                  },
                )
                .toList(),
          });
        }

        return _jsonResponse({'data': []});
      });
      final datasource = MemberRemoteDataSourceImpl(client: client);

      final companies = await datasource.getActiveMemberCompaniesByUserId();

      expect(
        companies.map((company) => company.branchCustomerId),
        containsAll(<int>[19, 39, 505, 617, 859]),
      );
      expect(companies, hasLength(5));
      expect(retriedBcid19, isTrue);

      final alshindo = companies.singleWhere(
        (company) => company.branchCustomerId == 19,
      );
      expect(alshindo.branchCustomerCode, 'BGR00019');
      expect(alshindo.gcidId, 19);
      expect(alshindo.gcName, 'ALSHINDO FOAM HI');
    },
  );
}

Map<String, dynamic> _requestSpec(Uri uri) {
  final raw = uri.queryParameters['spec'];
  if (raw == null || raw.isEmpty) return const {};
  return Map<String, dynamic>.from(jsonDecode(raw) as Map);
}

List<int> _idsFromFilters(List<dynamic> filters) {
  for (final rawFilter in filters) {
    if (rawFilter is! List || rawFilter.length < 3 || rawFilter.first != 'id') {
      continue;
    }
    if (rawFilter[1] == 'in' && rawFilter[2] is List) {
      return (rawFilter[2] as List).map((id) => (id as num).toInt()).toList();
    }
    if (rawFilter[1] == '=') return [(rawFilter[2] as num).toInt()];
  }
  return const [];
}

Map<String, dynamic> _branchCustomer(int id, {bool nestedGcid = false}) {
  return {
    'id': id,
    'name': id == 19 ? 'BGR00019' : 'BCID$id',
    'disabled': 0,
    'status': 'AKTIF',
    'gcid_id': id,
    'gcid': nestedGcid ? {'company_name': 'ALSHINDO FOAM HI'} : id,
    'branch': 56,
  };
}

http.Response _jsonResponse(Map<String, dynamic> body) {
  return http.Response(
    jsonEncode(body),
    200,
    headers: {'content-type': 'application/json'},
  );
}

class _TestClient extends http.BaseClient {
  _TestClient(this.handler);

  final Future<http.Response> Function(http.BaseRequest request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
      request: request,
    );
  }
}
