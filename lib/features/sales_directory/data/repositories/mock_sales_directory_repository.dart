import 'dart:convert';

import 'package:ekaplus_ekatunggal/features/sales_directory/data/models/sales_profile_model.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/domain/entities/sales_profile.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/domain/repositories/sales_directory_repository.dart';
import 'package:http/http.dart' as http;

class MockSalesDirectoryRepository implements SalesDirectoryRepository {
  MockSalesDirectoryRepository({http.Client? client, this.useRemote = true})
    : _client = client ?? http.Client();

  final http.Client _client;
  final bool useRemote;
  final Map<int, List<SalesProfile>> _cache = {};

  static const _templates = [
    (
      name: 'Contoh Sales A',
      position: 'Sales Executive',
      photoUrl: 'asset://assets/images/avatars/avatar_1.png',
    ),
    (
      name: 'Contoh Sales B',
      position: 'Sales Representative',
      photoUrl: 'asset://assets/images/avatars/avatar_2.png',
    ),
    (
      name: 'Contoh Sales C',
      position: 'Sales Executive',
      photoUrl: 'asset://assets/images/avatars/avatar_3.png',
    ),
    (
      name: 'Contoh Sales D',
      position: 'Sales Consultant',
      photoUrl: 'asset://assets/images/avatars/avatar_4.png',
    ),
  ];

  List<SalesProfile> _fallbackProfilesFor(int branchId) =>
      List.generate(_templates.length, (index) {
        final template = _templates[index];
        return SalesProfileModel(
          id: branchId * 100 + index + 1,
          name: template.name,
          position: template.position,
          division: 'Sales',
          branchId: branchId,
          photoUrl: template.photoUrl,
          description: 'Contoh profil tim sales Ekatunggal.',
          isDemo: true,
        );
      }, growable: false);

  Future<List<SalesProfile>> _profilesFor(int branchId) async {
    final cached = _cache[branchId];
    if (cached != null) return cached;

    if (useRemote) {
      try {
        final uri = Uri.https('randomuser.me', '/api/1.4/', {
          'results': '${_templates.length}',
          'seed': 'ekatunggal-$branchId',
          'inc': 'name,picture',
          'noinfo': '',
        });
        final response = await _client
            .get(uri)
            .timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final results = body['results'] as List<dynamic>? ?? const [];
          if (results.length >= _templates.length) {
            final profiles = List<SalesProfile>.generate(_templates.length, (
              index,
            ) {
              final user = results[index] as Map<String, dynamic>;
              final name = user['name'] as Map<String, dynamic>? ?? const {};
              final picture =
                  user['picture'] as Map<String, dynamic>? ?? const {};
              final fullName = [
                name['first']?.toString().trim(),
                name['last']?.toString().trim(),
              ].whereType<String>().where((part) => part.isNotEmpty).join(' ');
              final template = _templates[index];
              return SalesProfileModel(
                id: branchId * 100 + index + 1,
                name: fullName.isEmpty ? template.name : fullName,
                position: template.position,
                division: 'Sales',
                branchId: branchId,
                photoUrl: picture['large']?.toString().trim().isNotEmpty == true
                    ? picture['large'].toString().trim()
                    : template.photoUrl,
                description: 'Contoh profil tim sales Ekatunggal.',
                isDemo: true,
              );
            }, growable: false);
            _cache[branchId] = profiles;
            return profiles;
          }
        }
      } catch (_) {
        // Saat API tidak tersedia, Home tetap menampilkan fixture lokal.
      }
    }

    final fallback = _fallbackProfilesFor(branchId);
    _cache[branchId] = fallback;
    return fallback;
  }

  @override
  Future<List<SalesProfile>> getSales({
    required int branchId,
    String? query,
    String? position,
  }) async {
    if (branchId <= 0) return const [];
    final normalizedQuery = query?.trim().toLowerCase() ?? '';
    final normalizedPosition = position?.trim().toLowerCase() ?? '';
    final profiles = await _profilesFor(branchId);
    return profiles
        .where((profile) {
          final matchesQuery =
              normalizedQuery.isEmpty ||
              profile.name.toLowerCase().contains(normalizedQuery) ||
              profile.position.toLowerCase().contains(normalizedQuery);
          final matchesPosition =
              normalizedPosition.isEmpty ||
              profile.position.toLowerCase() == normalizedPosition;
          return matchesQuery && matchesPosition;
        })
        .toList(growable: false);
  }

  @override
  Future<SalesProfile?> getSalesById(int id) async {
    if (id <= 0) return null;
    final branchId = id ~/ 100;
    if (branchId <= 0) return null;
    for (final profile in await _profilesFor(branchId)) {
      if (profile.id == id) return profile;
    }
    return null;
  }
}
