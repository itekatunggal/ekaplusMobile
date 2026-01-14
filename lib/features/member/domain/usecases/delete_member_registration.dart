// lib/features/member/domain/usecases/delete_member_registration.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';

class DeleteMemberRegistration {
  final MemberRepository repository;

  const DeleteMemberRegistration(this.repository);

  Future<Either<Failure, void>> execute(int memberId) {
    return repository.deleteRegistration(memberId);
  }
}
