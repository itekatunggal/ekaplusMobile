import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:equatable/equatable.dart';

enum SelectedBranchStatus { initial, loading, ready, error }

class SelectedBranchState extends Equatable {
  const SelectedBranchState({
    this.status = SelectedBranchStatus.initial,
    this.branches = const [],
    this.selectedBranchId,
    this.message,
  });

  final SelectedBranchStatus status;
  final List<Branch> branches;
  final int? selectedBranchId;
  final String? message;

  Branch? get selectedBranch {
    for (final branch in branches) {
      if (branch.id == selectedBranchId) return branch;
    }
    return null;
  }

  @override
  List<Object?> get props => [status, branches, selectedBranchId, message];
}
