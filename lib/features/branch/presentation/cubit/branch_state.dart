import 'package:ekaplus_ekatunggal/features/branch/domain/entities/branch.dart';
import 'package:equatable/equatable.dart';

abstract class BranchState extends Equatable {
  const BranchState();

  @override
  List<Object?> get props => [];
}

class BranchInitial extends BranchState {}

class BranchLoading extends BranchState {}

class BranchListLoaded extends BranchState {
  final List<Branch> branches;

  const BranchListLoaded(this.branches);

  @override
  List<Object?> get props => [branches];
}

class BranchLoaded extends BranchState {
  final Branch branch;

  const BranchLoaded(this.branch);
}

class BranchError extends BranchState {
  final String message;

  const BranchError(this.message);

  @override
  List<Object?> get props => [message];
}
