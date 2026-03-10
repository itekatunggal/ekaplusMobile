import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/usecases/get_all_branches.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/usecases/get_branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/branch_state.dart';

class BranchCubit extends Cubit<BranchState> {
  final GetAllBranches getAllBranches;
  final GetBranch getBranch;

  BranchCubit({required this.getAllBranches, required this.getBranch})
    : super(BranchInitial());

  bool _isNetworkError(Failure failure) {
    return failure is NetworkFailure ||
        failure is TimeoutFailure ||
        (failure is ServerFailure &&
            (failure.statusCode == null || failure.statusCode! >= 500));
  }

  Future<void> fetchBranches({int page = 1}) async {
    emit(BranchLoading());

    final result = await getAllBranches.execute(page);

    result.fold(
      (failure) {
        // If network failure, keep showing loading (dialog will handle notification)
        if (_isNetworkError(failure)) {
          emit(BranchLoading());
        } else {
          emit(BranchError(failure.message ?? 'Failed to load branches'));
        }
      },
      (branches) {
        emit(BranchListLoaded(branches));
      },
    );
  }

  Future<void> fetchBranchById(int id) async {
    emit(BranchLoading());

    final result = await getBranch.execute(id);

    result.fold(
      (failure) {
        // If network failure, keep showing loading (dialog will handle notification)
        if (_isNetworkError(failure)) {
          emit(BranchLoading());
        } else {
          emit(BranchError(failure.message ?? 'Failed to load branch'));
        }
      },
      (branch) {
        emit(BranchLoaded(branch));
      },
    );
  }

  void reset() {
    emit(BranchInitial());
  }
}
