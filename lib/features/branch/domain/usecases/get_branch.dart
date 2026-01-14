// lib/features/category/domain/usecases/get_category.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/repositories/branch_repository.dart';

class GetBranch {
  final BranchRepository branchRepository;
  const GetBranch(this.branchRepository);

  Future<Either<Failure, Branch>> execute(int id) {
    return branchRepository.getBranch(id);
  }
}
