// lib/features/member/domain/usecases/get_all_member_registrations.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/member_registration.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';

class GetAllMemberRegistrations {
  final MemberRepository repository;

  const GetAllMemberRegistrations(this.repository);

  Future<Either<Failure, List<MemberRegistration>>> execute() {
    return repository.getAllRegistrations();
  }
}
