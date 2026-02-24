// lib/features/member/data/repositories/member_repository_implementation.dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
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
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemberRegistration>> getRegistrationById(
    int memberId,
  ) async {
    try {
      // final registration = await localDataSource.getRegistrationById(memberId);
      // return Right(registration);
      return Left(CacheFailure(message: ""));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, MemberRegistration>> saveRegistration(
    Map<String, dynamic> registration, {
    required Map<String, File> files,
  }) async {
    try {
      // Convert entity to model

      MemberRegistration data = await remoteDataSource.saveRegistration(
        registration,
        files: files,
      );
      return Right(data);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRegistration(
    int memberId,
    MemberRegistration registration,
  ) async {
    try {
      // final model = MemberRegistrationModel.fromEntity(registration);
      // await localDataSource.updateRegistration(memberId, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRegistration(int memberId) async {
    try {
      await remoteDataSource.deleteRegistration(memberId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemberRegistration>>>
  getRegistrationsByUserId() async {
    try {
      final registrations = await remoteDataSource.getRegistrationsByUserId();
      return Right(registrations);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemberRegistration>>> getRegistrationsByStatus(
    String status,
  ) async {
    try {
      // final registrations = await localDataSource.getRegistrationsByStatus(
      //   status,
      // );
      // return Right(registrations);
      return Left(CacheFailure(message: ""));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MemberRegistration>>> getApprovedGCIDsByUserId(
    int userId,
  ) async {
    try {
      // final registrations = await localDataSource.getApprovedGCIDsByUserId(
      //   userId,
      // );
      // return Right(registrations);
      return Left(CacheFailure(message: ""));
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ActiveMemberCompany>>>
  getActiveMemberCompaniesByUserId() async {
    try {
      final companies = await remoteDataSource.getActiveMemberCompaniesByUserId();
      return Right(companies);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
