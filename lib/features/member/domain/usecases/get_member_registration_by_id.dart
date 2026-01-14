// lib/features/member/domain/usecases/get_member_registration_by_id.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';

class GetMemberRegistrationById {
  final MemberRepository repository;

  const GetMemberRegistrationById(this.repository);

  Future<Either<Failure, MemberRegistration>> execute(int id) {
    return repository.getRegistrationById(id);
  }
}
