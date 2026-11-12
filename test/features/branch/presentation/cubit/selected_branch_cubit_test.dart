import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/repositories/branch_repository.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/usecases/get_all_branches.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_cubit.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _BranchRepository extends BranchRepository {
  _BranchRepository(this.branches);
  final List<Branch> branches;

  @override
  Future<Either<Failure, List<Branch>>> getAllBranches(int page) async =>
      Right(branches);

  @override
  Future<Either<Failure, Branch>> getBranch(int id) async =>
      Right(branches.firstWhere((branch) => branch.id == id));
}

void main() {
  const branches = [
    Branch(id: 10, branchName: 'Jakarta'),
    Branch(id: 20, branchName: 'Bandung'),
  ];

  test('uses the branch from the active customer', () async {
    final cubit = SelectedBranchCubit(
      getAllBranches: GetAllBranches(_BranchRepository(branches)),
    );
    cubit.syncWithActiveCustomerBranch(20);

    await cubit.load();

    expect(cubit.state.status, SelectedBranchStatus.ready);
    expect(cubit.state.selectedBranchId, 20);
    expect(cubit.state.selectedBranch?.branchName, 'Bandung');
    await cubit.close();
  });

  test(
    'does not fall back to another branch when customer branch is invalid',
    () async {
      final cubit = SelectedBranchCubit(
        getAllBranches: GetAllBranches(_BranchRepository(branches)),
      );
      cubit.syncWithActiveCustomerBranch(99);

      await cubit.load();

      expect(cubit.state.selectedBranchId, isNull);
      expect(cubit.state.selectedBranch, isNull);
      expect(cubit.state.message, 'Cabang customer aktif tidak tersedia');
      await cubit.close();
    },
  );

  test('changing the active customer automatically changes branch', () async {
    final cubit = SelectedBranchCubit(
      getAllBranches: GetAllBranches(_BranchRepository(branches)),
    );
    cubit.syncWithActiveCustomerBranch(10);
    await cubit.load();

    cubit.syncWithActiveCustomerBranch(20);

    expect(cubit.state.selectedBranchId, 20);
    expect(cubit.state.selectedBranch?.branchName, 'Bandung');
    await cubit.close();
  });

  test('has no active branch when there is no active customer', () async {
    final cubit = SelectedBranchCubit(
      getAllBranches: GetAllBranches(_BranchRepository(branches)),
    );

    await cubit.load();

    expect(cubit.state.selectedBranchId, isNull);
    await cubit.close();
  });
}
