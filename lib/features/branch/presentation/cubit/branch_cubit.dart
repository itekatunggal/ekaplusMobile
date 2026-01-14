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

  // Helper method to check if error is network-related
  bool _isNetworkError(Failure failure) {
    final errorMessage = failure.message?.toLowerCase() ?? '';
    return failure is NetworkFailure ||
        errorMessage.contains('socketexception') ||
        errorMessage.contains('no connection') ||
        errorMessage.contains('failed host lookup');
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
