import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/usecases/get_all_branches.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/usecases/get_branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/branch_state.dart';

class BranchCubit extends Cubit<BranchState> {
  final GetAllBranches getAllBranches;
  final GetBranch getBranch;

  BranchCubit({required this.getAllBranches, required this.getBranch})
    : super(BranchInitial());

  Future<void> fetchBranches({int page = 1}) async {
    emit(BranchLoading());

    final result = await getAllBranches.execute(page);

    result.fold(
      (failure) {
        emit(BranchError(failure.message ?? 'Gagal memuat cabang'));
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
        emit(BranchError(failure.message ?? 'Gagal memuat cabang'));
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
