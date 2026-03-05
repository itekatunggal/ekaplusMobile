// lib/features/member/presentation/cubit/member_registration_cubit.dart

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
// import 'package:path_provider/path_provider.dart';

import '../../data/models/branch_model.dart';
import '../../data/models/province_model.dart';
import '../../data/models/regency_model.dart';
import '../../data/models/district_model.dart';
import '../../data/models/village_model.dart';

import '../../domain/usecases/get_all_member_registrations.dart';
import '../../domain/usecases/save_member_registration.dart';
import '../../domain/usecases/update_member_registration.dart';
import '../../domain/usecases/get_member_registrations_by_user_id.dart';
import '../../domain/usecases/get_approved_gcids.dart';
import '../../domain/usecases/get_active_member_companies_by_user_id.dart';
import '../../domain/usecases/delete_member_registration.dart';

part 'member_registration_state.dart';

class MemberRegistrationCubit extends Cubit<MemberRegistrationState> {
  final GetAllMemberRegistrations getAllMemberRegistrations;
  final SaveMemberRegistration saveMemberRegistration;
  final UpdateMemberRegistration updateMemberRegistration;
  final GetMemberRegistrationsByUserId getMemberRegistrationsByUserId;
  final GetApprovedGCIDs getApprovedGCIDs;
  final GetActiveMemberCompaniesByUserId getActiveMemberCompaniesByUserId;
  final DeleteMemberRegistration deleteMemberRegistration;

  MemberRegistrationCubit({
    required this.getAllMemberRegistrations,
    required this.saveMemberRegistration,
    required this.updateMemberRegistration,
    required this.getMemberRegistrationsByUserId,
    required this.getApprovedGCIDs,
    required this.getActiveMemberCompaniesByUserId,
    required this.deleteMemberRegistration,
  }) : super(const MemberRegistrationInitial());

  static const String _wilayahApiBase = 'https://wilayah.id/api';

  void _emitSafe(MemberRegistrationState nextState) {
    if (isClosed) return;
    emit(nextState);
  }

  /// Create HTTP client that handles SSL certificate issues
  http.Client _createHttpClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Allow wilayah.id API in debug/development mode
        return !kReleaseMode || host == 'wilayah.id';
      };
    return IOClient(httpClient);
  }

  Future<void> loadBranches() async {
    try {
      _emitSafe(const MemberRegistrationLoading());

      final response = await rootBundle.loadString('assets/data/branches.json');
      final List<dynamic> data = jsonDecode(response);

      final branches = data
          .where((e) => e['disabled'] == 0)
          .map((e) => BranchModel.fromJson(e))
          .toList();

      _emitSafe(MemberRegistrationBranchesLoaded(branches));
    } catch (e) {
      _emitSafe(MemberRegistrationError('Gagal memuat data cabang: $e'));
    }
  }

  Future<void> loadProvinces() async {
    final client = _createHttpClient();
    try {
      _emitSafe(const MemberRegistrationLoading());

      final res = await client.get(
        Uri.parse('$_wilayahApiBase/provinces.json'),
      );

      if (res.statusCode != 200) {
        _emitSafe(const MemberRegistrationError('Gagal memuat data provinsi'));
        return;
      }

      final json = jsonDecode(res.body);
      final provinces = (json['data'] as List)
          .map((e) => ProvinceModel.fromJson(e))
          .toList();

      _emitSafe(MemberRegistrationProvincesLoaded(provinces));
    } catch (e) {
      _emitSafe(MemberRegistrationError('Error loading provinces: $e'));
    } finally {
      client.close();
    }
  }

  Future<void> loadRegencies(String provinceId) async {
    final client = _createHttpClient();
    try {
      _emitSafe(const MemberRegistrationLoading());

      final res = await client.get(
        Uri.parse('$_wilayahApiBase/regencies/$provinceId.json'),
      );

      if (res.statusCode != 200) {
        _emitSafe(const MemberRegistrationError('Gagal memuat data kabupaten'));
        return;
      }

      final json = jsonDecode(res.body);
      final regencies = (json['data'] as List)
          .map((e) => RegencyModel.fromJson(e))
          .toList();

      _emitSafe(MemberRegistrationRegenciesLoaded(regencies));
    } catch (e) {
      _emitSafe(MemberRegistrationError('Error loading regencies: $e'));
    } finally {
      client.close();
    }
  }

  Future<void> loadDistricts(String regencyId) async {
    final client = _createHttpClient();
    try {
      _emitSafe(const MemberRegistrationLoading());

      final res = await client.get(
        Uri.parse('$_wilayahApiBase/districts/$regencyId.json'),
      );

      if (res.statusCode != 200) {
        _emitSafe(const MemberRegistrationError('Gagal memuat data kecamatan'));
        return;
      }

      final json = jsonDecode(res.body);
      final districts = (json['data'] as List)
          .map((e) => DistrictModel.fromJson(e))
          .toList();

      _emitSafe(MemberRegistrationDistrictsLoaded(districts));
    } catch (e) {
      _emitSafe(MemberRegistrationError('Error loading districts: $e'));
    } finally {
      client.close();
    }
  }

  Future<void> loadVillages(String districtId) async {
    final client = _createHttpClient();
    try {
      _emitSafe(const MemberRegistrationLoading());

      final res = await client.get(
        Uri.parse('$_wilayahApiBase/villages/$districtId.json'),
      );

      if (res.statusCode != 200) {
        _emitSafe(const MemberRegistrationError('Gagal memuat data desa'));
        return;
      }

      final json = jsonDecode(res.body);
      final villages = (json['data'] as List)
          .map((e) => VillageModel.fromJson(e))
          .toList();

      _emitSafe(MemberRegistrationVillagesLoaded(villages));
    } catch (e) {
      _emitSafe(MemberRegistrationError('Error loading villages: $e'));
    } finally {
      client.close();
    }
  }

  Future<void> submitRegistration(
    Map<String, dynamic> entity, {
    required Map<String, File> files,
  }) async {
    try {
      _emitSafe(const MemberRegistrationLoading());

      final result = await saveMemberRegistration.execute(entity, files: files);

      result.fold(
        (failure) => _emitSafe(
          MemberRegistrationError(
            failure.message ?? 'Gagal menyimpan registrasi',
          ),
        ),
        (register) {
          _emitSafe(const MemberRegistrationSuccess());
        },
      );
    } catch (e) {
      _emitSafe(MemberRegistrationError('Gagal menyimpan data: $e'));
    }
  }

  Future<void> getUserRegistrations() async {
    try {
      _emitSafe(const MemberRegistrationLoading());

      final result = await getMemberRegistrationsByUserId.execute();

      result.fold(
        (failure) => _emitSafe(
          MemberRegistrationError(
            failure.message ?? 'Gagal memuat data registrasi',
          ),
        ),
        (data) => _emitSafe(MemberRegistrationUserRegistrationsLoaded(data)),
      );
    } catch (e) {
      _emitSafe(MemberRegistrationError('Error loading registrations: $e'));
    }
  }

  Future<void> loadApprovedGCIDs(int userId) async {
    try {
      _emitSafe(const MemberRegistrationLoading());

      final result = await getApprovedGCIDs.execute(userId);

      result.fold(
        (failure) => _emitSafe(MemberRegistrationError(failure.message ?? 'Gagal')),
        (data) => _emitSafe(MemberRegistrationApprovedGCIDsLoaded(data)),
      );
    } catch (e) {
      _emitSafe(MemberRegistrationError('Error loading GCID: $e'));
    }
  }

  Future<void> refreshRegistrations() async {
    try {
      _emitSafe(const MemberRegistrationLoading());

      final result = await getAllMemberRegistrations.execute();

      result.fold(
        (failure) => _emitSafe(MemberRegistrationError(failure.message ?? 'Gagal')),
        (data) => _emitSafe(MemberRegistrationAllRegistrationsLoaded(data)),
      );
    } catch (e) {
      _emitSafe(MemberRegistrationError('Error refreshing data: $e'));
    }
  }

  Future<void> getActiveMemberCompanies() async {
    try {
      _emitSafe(const MemberRegistrationActiveCompaniesLoading());

      final result = await getActiveMemberCompaniesByUserId.execute();
      result.fold(
        (failure) => _emitSafe(
          MemberRegistrationActiveCompaniesError(
            failure.message ?? 'Gagal memuat perusahaan aktif',
          ),
        ),
        (data) => _emitSafe(MemberRegistrationActiveCompaniesLoaded(data)),
      );
    } catch (e) {
      _emitSafe(MemberRegistrationActiveCompaniesError('Error loading active companies: $e'));
    }
  }

  Future<MemberRegistration?> saveDraft(
    Map<String, dynamic> entity, {
    required Map<String, File> files,
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) _emitSafe(const MemberRegistrationLoading());
      final payload = <String, dynamic>{...entity, 'status': 'Draft'};
      final result = await saveMemberRegistration.execute(payload, files: files);
      return result.fold((failure) {
        _emitSafe(
          MemberRegistrationError(
            failure.message ?? 'Gagal menyimpan draft pengajuan',
          ),
        );
        return null;
      }, (registration) {
        _emitSafe(MemberRegistrationDraftSaved(registration));
        return registration;
      });
    } catch (e) {
      _emitSafe(MemberRegistrationError('Gagal menyimpan draft: $e'));
      return null;
    }
  }

  Future<MemberRegistration?> submitAsRequest(
    Map<String, dynamic> entity, {
    required Map<String, File> files,
  }) async {
    try {
      _emitSafe(const MemberRegistrationLoading());
      final payload = <String, dynamic>{...entity, 'status': 'Request'};
      final result = await saveMemberRegistration.execute(payload, files: files);
      return result.fold((failure) {
        _emitSafe(
          MemberRegistrationError(
            failure.message ?? 'Gagal mengirim pengajuan',
          ),
        );
        return null;
      }, (registration) {
        _emitSafe(const MemberRegistrationSuccess());
        return registration;
      });
    } catch (e) {
      _emitSafe(MemberRegistrationError('Gagal mengirim pengajuan: $e'));
      return null;
    }
  }

  Future<bool> deleteDraft(int registrationId) async {
    try {
      _emitSafe(const MemberRegistrationLoading());
      final result = await deleteMemberRegistration.execute(registrationId);
      return result.fold((failure) {
        _emitSafe(
          MemberRegistrationError(
            failure.message ?? 'Gagal menghapus draft',
          ),
        );
        return false;
      }, (_) {
        _emitSafe(MemberRegistrationDraftDeleted(registrationId));
        return true;
      });
    } catch (e) {
      _emitSafe(MemberRegistrationError('Gagal menghapus draft: $e'));
      return false;
    }
  }

  // === SHIPPING ADDRESS METHODS ===

  Future<void> loadShippingProvinces(String addressId) async {
    final client = _createHttpClient();
    try {
      final res = await client.get(
        Uri.parse('$_wilayahApiBase/provinces.json'),
      );

      if (res.statusCode != 200) {
        _emitSafe(const MemberRegistrationError('Gagal memuat data provinsi'));
        return;
      }

      final json = jsonDecode(res.body);
      final provinces = (json['data'] as List)
          .map((e) => ProvinceModel.fromJson(e))
          .toList();

      _emitSafe(MemberRegistrationShippingProvincesLoaded(addressId, provinces));
    } catch (e) {
      _emitSafe(MemberRegistrationError('Error loading provinces: $e'));
    } finally {
      client.close();
    }
  }

  Future<void> loadShippingRegencies(
    String addressId,
    String provinceId,
  ) async {
    final client = _createHttpClient();
    try {
      final res = await client.get(
        Uri.parse('$_wilayahApiBase/regencies/$provinceId.json'),
      );

      if (res.statusCode != 200) {
        _emitSafe(const MemberRegistrationError('Gagal memuat data kabupaten'));
        return;
      }

      final json = jsonDecode(res.body);
      final regencies = (json['data'] as List)
          .map((e) => RegencyModel.fromJson(e))
          .toList();

      _emitSafe(MemberRegistrationShippingRegenciesLoaded(addressId, regencies));
    } catch (e) {
      _emitSafe(MemberRegistrationError('Error loading regencies: $e'));
    } finally {
      client.close();
    }
  }

  Future<void> loadShippingDistricts(String addressId, String regencyId) async {
    final client = _createHttpClient();
    try {
      final res = await client.get(
        Uri.parse('$_wilayahApiBase/districts/$regencyId.json'),
      );

      if (res.statusCode != 200) {
        _emitSafe(const MemberRegistrationError('Gagal memuat data kecamatan'));
        return;
      }

      final json = jsonDecode(res.body);
      final districts = (json['data'] as List)
          .map((e) => DistrictModel.fromJson(e))
          .toList();

      _emitSafe(MemberRegistrationShippingDistrictsLoaded(addressId, districts));
    } catch (e) {
      _emitSafe(MemberRegistrationError('Error loading districts: $e'));
    } finally {
      client.close();
    }
  }
}

