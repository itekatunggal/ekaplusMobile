import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:ekaplus_ekatunggal/features/branch/domain/usecases/get_all_branches.dart';
import 'package:ekaplus_ekatunggal/features/branch/presentation/cubit/selected_branch_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedBranchCubit extends Cubit<SelectedBranchState> {
  SelectedBranchCubit({required GetAllBranches getAllBranches})
    : _getAllBranches = getAllBranches,
      super(const SelectedBranchState());

  final GetAllBranches _getAllBranches;
  int? _activeCustomerBranchId;

  Future<void> load({bool force = false, int? preferredBranchId}) async {
    if (preferredBranchId != null) {
      _activeCustomerBranchId = preferredBranchId > 0
          ? preferredBranchId
          : null;
    }
    if (!force && state.status == SelectedBranchStatus.loading) return;
    final previous = state;
    emit(
      SelectedBranchState(
        status: SelectedBranchStatus.loading,
        branches: previous.branches,
        selectedBranchId: previous.selectedBranchId,
      ),
    );
    final result = await _getAllBranches.execute(1);
    await result.fold(
      (failure) async => emit(
        SelectedBranchState(
          status: SelectedBranchStatus.error,
          branches: previous.branches,
          selectedBranchId: previous.selectedBranchId,
          message: failure.message ?? 'Gagal memuat cabang',
        ),
      ),
      (rows) async {
        final branches = rows.where(_isVisible).toList(growable: false);
        if (branches.isEmpty) {
          emit(const SelectedBranchState(status: SelectedBranchStatus.ready));
          return;
        }

        final customerBranchId = _activeCustomerBranchId;
        final resolvedId =
            customerBranchId != null &&
                branches.any((branch) => branch.id == customerBranchId)
            ? customerBranchId
            : null;
        emit(
          SelectedBranchState(
            status: SelectedBranchStatus.ready,
            branches: branches,
            selectedBranchId: resolvedId,
            message: customerBranchId != null && resolvedId == null
                ? 'Cabang customer aktif tidak tersedia'
                : null,
          ),
        );
      },
    );
  }

  bool _isVisible(Branch branch) {
    if (branch.id <= 0 || branch.branchName.trim().isEmpty) return false;
    if (branch.disabled == true) return false;
    final status = branch.status?.trim().toLowerCase() ?? '';
    return status != 'inactive' &&
        status != 'disabled' &&
        status != 'closed' &&
        status != 'nonaktif';
  }

  void syncWithActiveCustomerBranch(int? branchId) {
    _activeCustomerBranchId = branchId != null && branchId > 0
        ? branchId
        : null;
    if (state.status == SelectedBranchStatus.initial) return;
    final resolvedId =
        _activeCustomerBranchId != null &&
            state.branches.any((branch) => branch.id == _activeCustomerBranchId)
        ? _activeCustomerBranchId
        : null;
    emit(
      SelectedBranchState(
        status: state.status,
        branches: state.branches,
        selectedBranchId: resolvedId,
        message: _activeCustomerBranchId != null && resolvedId == null
            ? 'Cabang customer aktif tidak tersedia'
            : state.status == SelectedBranchStatus.error
            ? state.message
            : null,
      ),
    );
  }
}
