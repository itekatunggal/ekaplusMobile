import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/entities/active_member_company.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/repositories/member_repository.dart';

class GetActiveMemberCompaniesByUserId {
  final MemberRepository repository;

  const GetActiveMemberCompaniesByUserId(this.repository);

  Future<Either<Failure, List<ActiveMemberCompany>>> execute() {
    return repository.getActiveMemberCompaniesByUserId();
  }
}
