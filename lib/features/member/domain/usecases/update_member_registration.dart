// lib/features/member/domain/usecases/update_member_registration.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';

class UpdateMemberRegistration {
  final MemberRepository repository;

  const UpdateMemberRegistration(this.repository);

  Future<Either<Failure, void>> execute(
    int memberId,
    MemberRegistration registration,
  ) {
    return repository.updateRegistration(memberId, registration);
  }
}
