// lib/features/member/data/services/member_storage_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

@Deprecated(
  'Use MemberLocalDataSource and MemberRepository instead. This service will be removed in the next version.',
)
class MemberStorageService {
  // Singleton pattern
  static final MemberStorageService _instance =
      MemberStorageService._internal();
  factory MemberStorageService() => _instance;
  MemberStorageService._internal();

  // File names
  static const String _memberRegisterFileName = 'member_register.json';

  // ============================================
  // 1. Get Local File Path
  // ============================================
  Future<File> _getLocalFile(String fileName) async {
    if (kIsWeb) {
      throw UnsupportedError('File operations not supported on web');
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');

    // Create file with empty array if not exists
    if (!await file.exists()) {
      if (fileName == _memberRegisterFileName) {
        await file.writeAsString(
          jsonEncode({
            'member_registrations': [],
            'last_updated': DateTime.now().toIso8601String(),
          }),
        );
      }
    }

    return file;
  }

  // ============================================
  // 2. Load Member Registrations
  // ============================================
  Future<List<Map<String, dynamic>>> loadMemberRegistrations() async {
    try {
      final file = await _getLocalFile(_memberRegisterFileName);
      final contents = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(contents);

      final List<dynamic> registrationsList =
          jsonData['member_registrations'] ?? [];

      return registrationsList.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // 3. Save Member Registration + Auto Copy to Assets
  // ============================================
  Future<void> saveMemberRegistration(
    Map<String, dynamic> newRegistration,
  ) async {
    try {
      // Load existing registrations
      final registrations = await loadMemberRegistrations();

      // Add new registration
      registrations.add(newRegistration);

      // Save to local storage
      await _saveMemberRegistrationsToFile(registrations);

      // ============================================
      // AUTO SAVE TO ASSETS (Development)
      // ============================================
      await _autoSaveToAssets(registrations);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // Helper: Save registrations to local file
  // ============================================
  Future<void> _saveMemberRegistrationsToFile(
    List<Map<String, dynamic>> registrations,
  ) async {
    final file = await _getLocalFile(_memberRegisterFileName);
    final jsonData = {
      'member_registrations': registrations,
      'last_updated': DateTime.now().toIso8601String(),
      'total_registrations': registrations.length,
    };

    // Write with pretty print
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(jsonData);
    await file.writeAsString(prettyJson);
  }

  // ============================================
  // AUTO SAVE TO ASSETS (Development Mode)
  // ============================================
  Future<void> _autoSaveToAssets(
    List<Map<String, dynamic>> newRegistrations,
  ) async {
    if (kIsWeb) {
      return;
    }

    try {
      // Path ke assets/data/member_register.json (project root)
      final projectPath = Directory.current.path;
      final assetsFile = File('$projectPath/assets/data/member_register.json');

      // Buat folder jika belum ada
      final assetsDir = Directory('$projectPath/assets/data');
      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
      }

      // Load existing data dari assets (jika ada)
      List<Map<String, dynamic>> existingRegistrations = [];
      if (await assetsFile.exists()) {
        try {
          final existingContent = await assetsFile.readAsString();
          final existingJson = jsonDecode(existingContent);
          if (existingJson is Map &&
              existingJson.containsKey('member_registrations')) {
            final List<dynamic> registrationsList =
                existingJson['member_registrations'];
            existingRegistrations = registrationsList
                .cast<Map<String, dynamic>>();
          }
        } catch (e) {
          rethrow;
        }
      }

      // Merge: Update existing or add new
      for (var newReg in newRegistrations) {
        final existingIndex = existingRegistrations.indexWhere(
          (r) => r['member_id'] == newReg['member_id'],
        );

        if (existingIndex != -1) {
          // Update existing
          existingRegistrations[existingIndex] = newReg;
        } else {
          // Add new
          existingRegistrations.add(newReg);
        }
      }

      // Save to assets dengan pretty print
      final assetsData = {
        'member_registrations': existingRegistrations,
        'last_updated': DateTime.now().toIso8601String(),
        'total_registrations': existingRegistrations.length,
      };

      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(assetsData);
      await assetsFile.writeAsString(prettyJson);
    } catch (e) {
      // Don't throw - this is optional for development
    }
  }

  // ============================================
  // 4. Get Member Registration by ID
  // ============================================
  Future<Map<String, dynamic>?> getMemberRegistrationById(
    String memberId,
  ) async {
    try {
      final registrations = await loadMemberRegistrations();
      return registrations.firstWhere(
        (reg) => reg['member_id'] == memberId,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // 5. Get Member Registrations by User ID
  // ============================================
  Future<List<Map<String, dynamic>>> getMemberRegistrationsByUserId(
    int userId,
  ) async {
    try {
      final registrations = await loadMemberRegistrations();
      return registrations.where((reg) => reg['user_id'] == userId).toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // Get Latest Member Registration by User ID
  // ============================================
  Future<Map<String, dynamic>?> getLatestMemberRegistrationByUserId(
    int userId,
  ) async {
    try {
      final registrations = await getMemberRegistrationsByUserId(userId);
      if (registrations.isEmpty) return null;

      // Sort by created_at descending (latest first)
      registrations.sort((a, b) {
        final aCreated = a['created_at'] ?? '';
        final bCreated = b['created_at'] ?? '';
        return bCreated.compareTo(aCreated);
      });

      return registrations.first;
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // Load from Assets (for development sync)
  // ============================================
  Future<void> syncFromAssets() async {
    if (kIsWeb) {
      return;
    }

    try {
      final projectPath = Directory.current.path;
      final assetsFile = File('$projectPath/assets/data/member_register.json');

      if (!await assetsFile.exists()) {
        return;
      }

      // Read from assets
      final assetsContent = await assetsFile.readAsString();
      final assetsJson = jsonDecode(assetsContent);

      if (assetsJson is Map && assetsJson.containsKey('member_registrations')) {
        final List<dynamic> registrationsList =
            assetsJson['member_registrations'];
        final registrations = registrationsList.cast<Map<String, dynamic>>();

        // Save to local storage ONLY (tidak auto-save balik ke assets)
        await _saveToLocalOnly(registrations);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // Helper: Save to Local Storage Only (No Auto-Save to Assets)
  // ============================================
  Future<void> _saveToLocalOnly(
    List<Map<String, dynamic>> registrations,
  ) async {
    try {
      // Hanya save ke local file, TIDAK call _autoSaveToAssets()
      await _saveMemberRegistrationsToFile(registrations);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // 6. Update Member Registration
  // ============================================
  Future<void> updateMemberRegistration(
    String memberId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final registrations = await loadMemberRegistrations();
      final index = registrations.indexWhere(
        (reg) => reg['member_id'] == memberId,
      );

      if (index != -1) {
        registrations[index] = {...registrations[index], ...updates};
        registrations[index]['updated_at'] = DateTime.now().toIso8601String();
        await _saveMemberRegistrationsToFile(registrations);
        await _autoSaveToAssets(registrations);
      } else {
        throw '⚠️ Member registration not found: $memberId';
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // 7. Delete Member Registration
  // ============================================
  Future<void> deleteMemberRegistration(String memberId) async {
    try {
      final registrations = await loadMemberRegistrations();
      registrations.removeWhere((reg) => reg['member_id'] == memberId);
      await _saveMemberRegistrationsToFile(registrations);
      await _autoSaveToAssets(registrations);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // 8. Get File Path (for debugging)
  // ============================================
  Future<String> getMemberRegistrationsFilePath() async {
    final file = await _getLocalFile(_memberRegisterFileName);
    return file.path;
  }

  // ============================================
  // 9. Get Assets File Path
  // ============================================
  String getAssetsFilePath() {
    final projectPath = Directory.current.path;
    return '$projectPath/assets/data/member_register.json';
  }

  // ============================================
  // 10. Save All Registrations
  // ============================================
  Future<void> saveAllMemberRegistrations(
    List<Map<String, dynamic>> registrations,
  ) async {
    try {
      await _saveMemberRegistrationsToFile(registrations);
      await _autoSaveToAssets(registrations);
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // 11. Get Approved GCID Registrations by User ID
  // ============================================
  /// Returns list of approved GCID registrations for a user
  /// Used for dropdown when adding BCID (branch)
  Future<List<Map<String, dynamic>>> getApprovedGCIDsByUserId(
    int userId,
  ) async {
    try {
      final registrations = await getMemberRegistrationsByUserId(userId);
      return registrations.where((reg) {
        return reg['registration_type'] == 'GCID' &&
            reg['status'] == 'approved';
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // 12. Get Registrations Grouped by GCID
  // ============================================
  /// Returns registrations grouped by GCID for display in Member List

  Future<Map<String, List<Map<String, dynamic>>>> getRegistrationsGroupedByGCID(
    int userId,
  ) async {
    try {
      final registrations = await getMemberRegistrationsByUserId(userId);
      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (var reg in registrations) {
        final gcid = reg['gcid'];
        if (gcid != null && gcid.toString().isNotEmpty) {
          if (!grouped.containsKey(gcid)) {
            grouped[gcid] = [];
          }
          grouped[gcid]!.add(reg);
        }
      }

      // Sort each group by registration_type (GCID first, then BCID)
      grouped.forEach((gcid, list) {
        list.sort((a, b) {
          if (a['registration_type'] == 'GCID') return -1;
          if (b['registration_type'] == 'GCID') return 1;
          return 0;
        });
      });

      return grouped;
    } catch (e) {
      return {};
    }
  }

  // ============================================
  // 13. Get GCID Registration Data
  // ============================================
  /// Returns the GCID registration data for pre-filling BCID form
  Future<Map<String, dynamic>?> getGCIDRegistration(String gcid) async {
    try {
      final registrations = await loadMemberRegistrations();
      return registrations.firstWhere(
        (reg) => reg['gcid'] == gcid && reg['registration_type'] == 'GCID',
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }
}
