// lib/features/member/domain/repositories/member_repository.dart
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';

abstract class MemberRepository {
  /// Get all member registrations
  Future<Either<Failure, List<MemberRegistration>>> getAllRegistrations();

  /// Get member registration by ID
  Future<Either<Failure, MemberRegistration>> getRegistrationById(int memberId);

  /// Save new member registration
  Future<Either<Failure, MemberRegistration>> saveRegistration(
    Map<String, dynamic> registration, {
    required Map<String, File> files,
  });

  /// Update existing member registration
  Future<Either<Failure, void>> updateRegistration(
    int memberId,
    MemberRegistration registration,
  );

  /// Delete member registration
  Future<Either<Failure, void>> deleteRegistration(int memberId);

  /// Get member registrations by user ID
  Future<Either<Failure, List<MemberRegistration>>> getRegistrationsByUserId();

  /// Get member registrations by status (pending, approved, rejected)
  Future<Either<Failure, List<MemberRegistration>>> getRegistrationsByStatus(
    String status,
  );

  /// Get approved GCID registrations by user ID (for BCID form dropdown)
  Future<Either<Failure, List<MemberRegistration>>> getApprovedGCIDsByUserId(
    int userId,
  );
}
