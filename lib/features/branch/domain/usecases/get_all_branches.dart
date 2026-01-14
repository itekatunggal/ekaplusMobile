// lib/features/category/domain/usecases/get_all_category.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/repositories/branch_repository.dart';

class GetAllBranches {
  final BranchRepository branchRepository;
  const GetAllBranches(this.branchRepository);

  Future<Either<Failure, List<Branch>>> execute(int page) {
    return branchRepository.getAllBranches(page);
  }
}
