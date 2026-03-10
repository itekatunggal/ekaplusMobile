import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/core/error/failure_mapper.dart';
import 'package:ekaplus_ekatunggal/features/branch/data/datasources/branch_remote_datasource.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/repositories/branch_repository.dart';

class BranchRepositoryImplementation extends BranchRepository {
  final BranchRemoteDatasource branchRemoteDatasource;

  BranchRepositoryImplementation({required this.branchRemoteDatasource});

  @override
  Future<Either<Failure, List<Branch>>> getAllBranches(int page) async {
    try {
      final result = await branchRemoteDatasource.getAllBranches(1);
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackMessage: 'Gagal memuat cabang'),
      );
    }
  }

  @override
  Future<Either<Failure, Branch>> getBranch(int id) async {
    try {
      final result = await branchRemoteDatasource.getBranch(id);
      return Right(result);
    } catch (e) {
      return Left(
        mapExceptionToFailure(e, fallbackMessage: 'Gagal memuat detail cabang'),
      );
    }
  }
}
