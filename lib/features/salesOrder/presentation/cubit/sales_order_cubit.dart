import 'package:ekaplus_ekatunggal/features/salesOrder/data/models/sales_order_model.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/branch_credential_service.dart';
import 'package:ekaplus_ekatunggal/features/salesOrder/data/services/sales_order_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class SalesOrderState {
  const SalesOrderState();
}

class SalesOrderInitial extends SalesOrderState {
  const SalesOrderInitial();
}

class SalesOrderLoading extends SalesOrderState {
  const SalesOrderLoading();
}

class SalesOrderLoaded extends SalesOrderState {
  const SalesOrderLoaded({
    required this.items,
    required this.page,
    required this.hasMore,
    required this.total,
    this.isLoadingMore = false,
    this.loadMoreError,
  });
  final List<SalesOrder> items;
  final int page, total;
  final bool hasMore, isLoadingMore;
  final String? loadMoreError;
  SalesOrderLoaded copyWith({
    List<SalesOrder>? items,
    int? page,
    bool? hasMore,
    int? total,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) => SalesOrderLoaded(
    items: items ?? this.items,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
    total: total ?? this.total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreError: clearLoadMoreError
        ? null
        : loadMoreError ?? this.loadMoreError,
  );
}

class SalesOrderUnauthorized extends SalesOrderState {
  const SalesOrderUnauthorized(this.message);
  final String message;
}

class SalesOrderError extends SalesOrderState {
  const SalesOrderError(this.message);
  final String message;
}

class SalesOrderCubit extends Cubit<SalesOrderState> {
  SalesOrderCubit({
    BranchCredentialService? credentialService,
    SalesOrderService? salesOrderService,
  }) : _credentialService = credentialService ?? BranchCredentialService(),
       _service = salesOrderService ?? SalesOrderService(),
       super(const SalesOrderInitial());
  final BranchCredentialService _credentialService;
  final SalesOrderService _service;
  String _branchCode = '', _search = '';
  String? _status;
  BranchCredential? _credential;

  Future<void> loadSalesOrder({
    required String branchCode,
    required String bcid,
    String? status,
    String search = '',
    bool refresh = false,
  }) async {
    if (state is SalesOrderLoading && !refresh) return;
    _branchCode = branchCode;
    _status = status;
    _search = search;
    final previous = state is SalesOrderLoaded
        ? state as SalesOrderLoaded
        : null;
    if (!refresh || previous == null) emit(const SalesOrderLoading());
    try {
      _credential = await _credentialService.fetchCredential(branchCode);
      if (_credential == null || _credential!.token.isEmpty) {
        emit(
          const SalesOrderUnauthorized(
            'Credential tidak ditemukan untuk perusahaan ini.',
          ),
        );
        return;
      }
      final result = await _service.fetchSalesOrders(
        baseUrl: _credential!.url,
        token: _credential!.token,
        status: status,
        search: search,
      );
      emit(
        SalesOrderLoaded(
          items: result.items,
          page: result.page,
          hasMore: result.hasNext,
          total: result.total,
        ),
      );
    } on SalesOrderApiException catch (e) {
      if ((e.statusCode == 401 || e.statusCode == 403)) {
        emit(SalesOrderUnauthorized(e.message));
      } else if (previous != null && refresh) {
        emit(previous.copyWith(loadMoreError: e.message));
      } else {
        emit(SalesOrderError(e.message));
      }
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! SalesOrderLoaded ||
        !current.hasMore ||
        current.isLoadingMore ||
        _credential == null) {
      return;
    }
    emit(current.copyWith(isLoadingMore: true, clearLoadMoreError: true));
    try {
      final result = await _service.fetchSalesOrders(
        baseUrl: _credential!.url,
        token: _credential!.token,
        page: current.page + 1,
        status: _status,
        search: _search,
      );
      emit(
        current.copyWith(
          items: [...current.items, ...result.items],
          page: result.page,
          hasMore: result.hasNext,
          total: result.total,
          isLoadingMore: false,
          clearLoadMoreError: true,
        ),
      );
    } on SalesOrderApiException catch (e) {
      emit(current.copyWith(isLoadingMore: false, loadMoreError: e.message));
    }
  }

  Future<void> refresh() => loadSalesOrder(
    branchCode: _branchCode,
    bcid: '',
    status: _status,
    search: _search,
    refresh: true,
  );
}
