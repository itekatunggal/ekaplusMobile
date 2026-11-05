import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/core/error/failure_mapper.dart';
import 'package:ekaplus_ekatunggal/features/member/data/datasources/member_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';

class MemberRepositoryImplementation implements MemberRepository {
  final MemberRemoteDataSource remoteDataSource;

  MemberRepositoryImplementation({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MemberRegistration>>>
  getAllRegistrations() async {
    try {
      final registrations = await remoteDataSource.loadAllRegistrations();
      return Right(registrations);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackMessage: 'Gagal memuat registrasi'),
      );
    }
  }

  @override
  Future<Either<Failure, MemberRegistration>> getRegistrationById(
    int memberId,
  ) async {
    try {
      return const Left(UnknownFailure(message: 'Belum diimplementasikan'));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, MemberRegistration>> saveRegistration(
    Map<String, dynamic> registration, {
    required Map<String, File> files,
  }) async {
    try {
      final data = await remoteDataSource.saveRegistration(
        registration,
        files: files,
      );
      return Right(data);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackMessage: 'Gagal menyimpan registrasi'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateRegistration(
    int memberId,
    MemberRegistration registration,
  ) async {
    try {
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRegistration(int memberId) async {
    try {
      await remoteDataSource.deleteRegistration(memberId);
      return const Right(null);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackMessage: 'Gagal menghapus registrasi'),
      );
    }
  }

  @override
  Future<Either<Failure, List<MemberRegistration>>>
  getRegistrationsByUserId() async {
    try {
      final registrations = await remoteDataSource.getRegistrationsByUserId();
      return Right(registrations);
    } catch (e) {
      return Left(
        mapExceptionToFailure(
          e,
          fallbackMessage: 'Gagal memuat registrasi pengguna',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<MemberRegistration>>> getRegistrationsByStatus(
    String status,
  ) async {
    try {
      return const Left(UnknownFailure(message: 'Belum diimplementasikan'));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<MemberRegistration>>> getApprovedGCIDsByUserId(
    int userId,
  ) async {
    try {
      return const Left(UnknownFailure(message: 'Belum diimplementasikan'));
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<ActiveMemberCompany>>>
  getActiveMemberCompaniesByUserId() async {
    try {
      final companies = await remoteDataSource
          .getActiveMemberCompaniesByUserId();
      return Right(companies);
    } catch (e) {
      return Left(
        mapExceptionToFailure(
          e,
          fallbackMessage: 'Gagal memuat perusahaan aktif',
        ),
      );
    }
  }
}
