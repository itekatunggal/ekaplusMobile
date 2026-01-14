// lib/features/member/domain/usecases/get_member_registrations_by_user_id.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';

class GetMemberRegistrationsByUserId {
  final MemberRepository repository;

  const GetMemberRegistrationsByUserId(this.repository);

  Future<Either<Failure, List<MemberRegistration>>> execute() {
    return repository.getRegistrationsByUserId();
  }
}
