// lib/features/member/domain/usecases/get_approved_gcids.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';

class GetApprovedGCIDs {
  final MemberRepository repository;

  const GetApprovedGCIDs(this.repository);

  Future<Either<Failure, List<MemberRegistration>>> execute(int userId) {
    return repository.getApprovedGCIDsByUserId(userId);
  }
}
