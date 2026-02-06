// lib/features/member/presentation/cubit/member_registration_cubit.dart

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:path_provider/path_provider.dart';

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

part 'member_registration_state.dart';

class MemberRegistrationCubit extends Cubit<MemberRegistrationState> {
  final GetAllMemberRegistrations getAllMemberRegistrations;
  final SaveMemberRegistration saveMemberRegistration;
  final UpdateMemberRegistration updateMemberRegistration;
  final GetMemberRegistrationsByUserId getMemberRegistrationsByUserId;
  final GetApprovedGCIDs getApprovedGCIDs;

  MemberRegistrationCubit({
    required this.getAllMemberRegistrations,
    required this.saveMemberRegistration,
    required this.updateMemberRegistration,
    required this.getMemberRegistrationsByUserId,
    required this.getApprovedGCIDs,
  }) : super(const MemberRegistrationInitial());

  static const String _wilayahApiBase = 'https://wilayah.id/api';

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
      emit(const MemberRegistrationLoading());

      final response = await rootBundle.loadString('assets/data/branches.json');
      final List<dynamic> data = jsonDecode(response);

      final branches = data
          .where((e) => e['disabled'] == 0)
          .map((e) => BranchModel.fromJson(e))
          .toList();

      emit(MemberRegistrationBranchesLoaded(branches));
    } catch (e) {
      emit(MemberRegistrationError('Gagal memuat data cabang: $e'));
    }
  }

  Future<void> loadProvinces() async {
    final client = _createHttpClient();
    try {
      emit(const MemberRegistrationLoading());

      final res = await client.get(
        Uri.parse('$_wilayahApiBase/provinces.json'),
      );

      if (res.statusCode != 200) {
        emit(const MemberRegistrationError('Gagal memuat data provinsi'));
        return;
      }

      final json = jsonDecode(res.body);
      final provinces = (json['data'] as List)
          .map((e) => ProvinceModel.fromJson(e))
          .toList();

      emit(MemberRegistrationProvincesLoaded(provinces));
    } catch (e) {
      emit(MemberRegistrationError('Error loading provinces: $e'));
    } finally {
      client.close();
    }
  }

  Future<void> loadRegencies(String provinceId) async {
    final client = _createHttpClient();
    try {
      emit(const MemberRegistrationLoading());

      final res = await client.get(
        Uri.parse('$_wilayahApiBase/regencies/$provinceId.json'),
      );

      if (res.statusCode != 200) {
        emit(const MemberRegistrationError('Gagal memuat data kabupaten'));
        return;
      }

      final json = jsonDecode(res.body);
      final regencies = (json['data'] as List)
          .map((e) => RegencyModel.fromJson(e))
          .toList();

      emit(MemberRegistrationRegenciesLoaded(regencies));
    } catch (e) {
      emit(MemberRegistrationError('Error loading regencies: $e'));
    } finally {
      client.close();
    }
  }

  Future<void> loadDistricts(String regencyId) async {
    final client = _createHttpClient();
    try {
      emit(const MemberRegistrationLoading());

      final res = await client.get(
        Uri.parse('$_wilayahApiBase/districts/$regencyId.json'),
      );

      if (res.statusCode != 200) {
        emit(const MemberRegistrationError('Gagal memuat data kecamatan'));
        return;
      }

      final json = jsonDecode(res.body);
      final districts = (json['data'] as List)
          .map((e) => DistrictModel.fromJson(e))
          .toList();

      emit(MemberRegistrationDistrictsLoaded(districts));
    } catch (e) {
      emit(MemberRegistrationError('Error loading districts: $e'));
    } finally {
      client.close();
    }
  }

  Future<void> loadVillages(String districtId) async {
    final client = _createHttpClient();
    try {
      emit(const MemberRegistrationLoading());

      final res = await client.get(
        Uri.parse('$_wilayahApiBase/villages/$districtId.json'),
      );

      if (res.statusCode != 200) {
        emit(const MemberRegistrationError('Gagal memuat data desa'));
        return;
      }

      final json = jsonDecode(res.body);
      final villages = (json['data'] as List)
          .map((e) => VillageModel.fromJson(e))
          .toList();

      emit(MemberRegistrationVillagesLoaded(villages));
    } catch (e) {
      emit(MemberRegistrationError('Error loading villages: $e'));
    } finally {
      client.close();
    }
  }

  Future<void> submitRegistration(
    Map<String, dynamic> entity, {
    required Map<String, File> files,
  }) async {
    try {
      emit(const MemberRegistrationLoading());

      final result = await saveMemberRegistration.execute(entity, files: files);

      result.fold(
        (failure) => emit(
          MemberRegistrationError(
            failure.message ?? 'Gagal menyimpan registrasi',
          ),
        ),
        (register) {
          emit(const MemberRegistrationSuccess());
        },
      );
    } catch (e) {
      emit(MemberRegistrationError('Gagal menyimpan data: $e'));
    }
  }

  Future<void> getUserRegistrations() async {
    try {
      emit(const MemberRegistrationLoading());

      final result = await getMemberRegistrationsByUserId.execute();

      result.fold(
        (failure) => emit(
          MemberRegistrationError(
            failure.message ?? 'Gagal memuat data registrasi',
          ),
        ),
        (data) => emit(MemberRegistrationUserRegistrationsLoaded(data)),
      );
    } catch (e) {
      emit(MemberRegistrationError('Error loading registrations: $e'));
    }
  }

  Future<void> loadApprovedGCIDs(int userId) async {
    try {
      emit(const MemberRegistrationLoading());

      final result = await getApprovedGCIDs.execute(userId);

      result.fold(
        (failure) => emit(MemberRegistrationError(failure.message ?? 'Gagal')),
        (data) => emit(MemberRegistrationApprovedGCIDsLoaded(data)),
      );
    } catch (e) {
      emit(MemberRegistrationError('Error loading GCID: $e'));
    }
  }

  Future<void> refreshRegistrations() async {
    try {
      emit(const MemberRegistrationLoading());

      final result = await getAllMemberRegistrations.execute();

      result.fold(
        (failure) => emit(MemberRegistrationError(failure.message ?? 'Gagal')),
        (data) => emit(MemberRegistrationAllRegistrationsLoaded(data)),
      );
    } catch (e) {
      emit(MemberRegistrationError('Error refreshing data: $e'));
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
        emit(const MemberRegistrationError('Gagal memuat data provinsi'));
        return;
      }

      final json = jsonDecode(res.body);
      final provinces = (json['data'] as List)
          .map((e) => ProvinceModel.fromJson(e))
          .toList();

      emit(MemberRegistrationShippingProvincesLoaded(addressId, provinces));
    } catch (e) {
      emit(MemberRegistrationError('Error loading provinces: $e'));
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
        emit(const MemberRegistrationError('Gagal memuat data kabupaten'));
        return;
      }

      final json = jsonDecode(res.body);
      final regencies = (json['data'] as List)
          .map((e) => RegencyModel.fromJson(e))
          .toList();

      emit(MemberRegistrationShippingRegenciesLoaded(addressId, regencies));
    } catch (e) {
      emit(MemberRegistrationError('Error loading regencies: $e'));
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
        emit(const MemberRegistrationError('Gagal memuat data kecamatan'));
        return;
      }

      final json = jsonDecode(res.body);
      final districts = (json['data'] as List)
          .map((e) => DistrictModel.fromJson(e))
          .toList();

      emit(MemberRegistrationShippingDistrictsLoaded(addressId, districts));
    } catch (e) {
      emit(MemberRegistrationError('Error loading districts: $e'));
    } finally {
      client.close();
    }
  }
}
