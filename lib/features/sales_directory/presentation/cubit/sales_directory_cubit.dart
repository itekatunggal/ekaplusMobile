import 'package:ekaplus_ekatunggal/features/sales_directory/domain/repositories/sales_directory_repository.dart';
import 'package:ekaplus_ekatunggal/features/sales_directory/presentation/cubit/sales_directory_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SalesDirectoryCubit extends Cubit<SalesDirectoryState> {
  SalesDirectoryCubit(this._repository) : super(const SalesDirectoryState());

  final SalesDirectoryRepository _repository;
  int _requestVersion = 0;

  Future<void> load({
    required int branchId,
    String query = '',
    String? position,
  }) async {
    final version = ++_requestVersion;
    final branchChanged = state.branchId != branchId;
    emit(
      SalesDirectoryState(
        status: SalesDirectoryStatus.loading,
        branchId: branchId,
        profiles: branchChanged ? const [] : state.profiles,
        availablePositions: branchChanged ? const [] : state.availablePositions,
        query: query,
        position: position,
      ),
    );
    try {
      final allProfiles = await _repository.getSales(branchId: branchId);
      final positions =
          allProfiles.map((item) => item.position).toSet().toList()..sort();
      final profiles =
          query.trim().isEmpty && (position?.trim().isEmpty ?? true)
          ? allProfiles
          : await _repository.getSales(
              branchId: branchId,
              query: query,
              position: position,
            );
      if (version != _requestVersion || isClosed) return;
      emit(
        SalesDirectoryState(
          status: SalesDirectoryStatus.ready,
          branchId: branchId,
          profiles: profiles,
          availablePositions: positions,
          query: query,
          position: position,
        ),
      );
    } catch (_) {
      if (version != _requestVersion || isClosed) return;
      emit(
        SalesDirectoryState(
          status: SalesDirectoryStatus.error,
          branchId: branchId,
          query: query,
          position: position,
          message: 'Data sales belum dapat dimuat',
        ),
      );
    }
  }
}
