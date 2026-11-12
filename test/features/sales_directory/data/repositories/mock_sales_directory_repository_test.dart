import 'package:ekaplus_ekatunggal/features/sales_directory/data/repositories/mock_sales_directory_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final repository = MockSalesDirectoryRepository(useRemote: false);

  test('returns only demo sales scoped to the requested branch', () async {
    final rows = await repository.getSales(branchId: 56);

    expect(rows, isNotEmpty);
    expect(rows.every((row) => row.branchId == 56), isTrue);
    expect(rows.every((row) => row.isDemo), isTrue);
    expect(rows.every((row) => row.workPhone == null), isTrue);
    expect(rows.every((row) => row.workWhatsapp == null), isTrue);
  });

  test(
    'filters by query and position without leaking another branch',
    () async {
      final rows = await repository.getSales(
        branchId: 10,
        query: 'Contoh Sales A',
        position: 'Sales Executive',
      );

      expect(rows, hasLength(1));
      expect(rows.single.name, 'Contoh Sales A');
      expect(
        rows.single.photoUrl,
        'asset://assets/images/avatars/avatar_1.png',
      );
      expect(rows.single.branchId, 10);
    },
  );

  test('resolves a generated profile by id for deep links', () async {
    final rows = await repository.getSales(branchId: 20);

    final profile = await repository.getSalesById(rows.first.id);

    expect(profile, isNotNull);
    expect(profile!.branchId, 20);
  });

  test('returns empty state for an unmatched search', () async {
    final rows = await repository.getSales(
      branchId: 10,
      query: 'nama-yang-tidak-tersedia',
    );

    expect(rows, isEmpty);
  });

  test('uses names and photos returned by randomuser.me', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'randomuser.me');
      expect(request.url.queryParameters['results'], '4');
      expect(request.url.queryParameters['seed'], 'ekatunggal-56');
      return http.Response('''
        {"results":[
          {"name":{"first":"Ayu","last":"Pratama"},"picture":{"large":"https://randomuser.me/a.jpg"}},
          {"name":{"first":"Budi","last":"Santoso"},"picture":{"large":"https://randomuser.me/b.jpg"}},
          {"name":{"first":"Citra","last":"Lestari"},"picture":{"large":"https://randomuser.me/c.jpg"}},
          {"name":{"first":"Dimas","last":"Wijaya"},"picture":{"large":"https://randomuser.me/d.jpg"}}
        ]}
      ''', 200);
    });
    final remoteRepository = MockSalesDirectoryRepository(client: client);

    final rows = await remoteRepository.getSales(branchId: 56);

    expect(rows.first.name, 'Ayu Pratama');
    expect(rows.first.photoUrl, 'https://randomuser.me/a.jpg');
  });
}
