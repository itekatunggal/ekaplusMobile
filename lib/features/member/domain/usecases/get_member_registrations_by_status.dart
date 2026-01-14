// lib/features/member/domain/usecases/get_member_registrations_by_status.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';

class GetMemberRegistrationsByStatus {
  final MemberRepository repository;

  const GetMemberRegistrationsByStatus(this.repository);

  Future<Either<Failure, List<MemberRegistration>>> execute(String status) {
    return repository.getRegistrationsByStatus(status);
  }
}
