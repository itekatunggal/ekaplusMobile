// lib/features/category/domain/repositories/category_repository.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';

abstract class BranchRepository {
  Future<Either<Failure, List<Branch>>> getAllBranches(int page);
  Future<Either<Failure, Branch>> getBranch(int id);
}
