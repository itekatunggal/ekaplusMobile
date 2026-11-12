import 'package:ekaplus_ekatunggal/features/promotion/domain/entities/promotion.dart';
import 'package:ekaplus_ekatunggal/features/promotion/domain/repositories/promotion_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PromotionStatus { initial, loading, ready, error }

class PromotionState extends Equatable {
  const PromotionState({
    this.status = PromotionStatus.initial,
    this.items = const [],
    this.query = '',
    this.branchId,
    this.message,
  });
  final PromotionStatus status;
  final List<Promotion> items;
  final String query;
  final int? branchId;
  final String? message;
  @override
  List<Object?> get props => [status, items, query, branchId, message];
}

class PromotionCubit extends Cubit<PromotionState> {
  PromotionCubit(this._repository) : super(const PromotionState());
  final PromotionRepository _repository;
  int _version = 0;

  Future<void> load({int? branchId, String query = ''}) async {
    final version = ++_version;
    emit(
      PromotionState(
        status: PromotionStatus.loading,
        items: state.items,
        query: query,
        branchId: branchId,
      ),
    );
    try {
      final items = await _repository.getPromotions(
        branchId: branchId,
        query: query,
      );
      if (version != _version || isClosed) return;
      emit(
        PromotionState(
          status: PromotionStatus.ready,
          items: items,
          query: query,
          branchId: branchId,
        ),
      );
    } catch (_) {
      if (version != _version || isClosed) return;
      emit(
        PromotionState(
          status: PromotionStatus.error,
          query: query,
          branchId: branchId,
          message: 'Promo belum dapat dimuat',
        ),
      );
    }
  }
}
