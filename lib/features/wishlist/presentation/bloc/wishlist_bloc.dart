// lib/features/wishlist/presentation/bloc/wishlist_bloc.dart
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/check_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/get_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/toggle_wishlist.dart';
import 'package:ekaplus_ekatunggal/features/wishlist/domain/usecases/bulk_delete_wishlist.dart';
import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final GetWishlist getWishlist;
  final ToggleWishlist toggleWishlist;
  final CheckWishlist checkWishlist;
  final BulkDeleteWishlist bulkDeleteWishlist;

  static const int _defaultLimit = 20;

  bool _isNetworkError(Failure failure) {
    return failure is NetworkFailure ||
        failure is TimeoutFailure ||
        (failure is ServerFailure &&
            (failure.statusCode == null || failure.statusCode! >= 500));
  }

  WishlistBloc({
    required this.getWishlist,
    required this.toggleWishlist,
    required this.checkWishlist,
    required this.bulkDeleteWishlist,
  }) : super(WishlistInitial()) {
    on<LoadWishlistFirstPage>(_onLoadFirstPage);
    on<LoadWishlistNextPage>(_onLoadNextPage);
    on<RefreshWishlist>(_onRefresh);
    on<LoadWishlist>(_onLoadWishlist);
    on<ToggleWishlistItem>(_onToggleWishlistItem);
    on<CheckWishlistStatus>(_onCheckWishlistStatus);
    on<BulkDeleteWishlistItems>(_onBulkDeleteWishlistItems);
    on<ClearWishlistCache>(_onClearCache);
  }

  Future<void> _onLoadFirstPage(
    LoadWishlistFirstPage event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());

    final userData = await SessionManager.getCurrentUser();
    if (userData == null) {
      emit(
        WishlistLoaded(
          items: [],
          statusMap: {},
          page: 1,
          limit: _defaultLimit,
          hasMore: false,
        ),
      );
      return;
    }

    final user = UserModel.fromLocalJson(userData);
    final limit = event.limit ?? _defaultLimit;

    final result = await getWishlist(
      user.id,
      page: 1,
      limit: limit,
      search: event.search,
      filters: event.filters,
      orderBy: event.orderBy,
      fields: event.fields,
    );

    result.fold(
      (failure) {
        // If network failure, keep showing shimmer (dialog will handle notification)
        if (_isNetworkError(failure)) {
          emit(WishlistLoading());
        } else {
          emit(WishlistError(failure.message ?? ''));
        }
      },
      (items) {
        emit(
          WishlistLoaded(
            items: items,
            statusMap: {},
            page: 1,
            limit: limit,
            hasMore: items.length == limit,
            search: event.search,
            filters: event.filters,
            orderBy: event.orderBy,
            fields: event.fields,
          ),
        );
      },
    );
  }

  Future<void> _onLoadNextPage(
    LoadWishlistNextPage event,
    Emitter<WishlistState> emit,
  ) async {
    final current = state;
    if (current is! WishlistLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final userData = await SessionManager.getCurrentUser();
    if (userData == null) return;

    final user = UserModel.fromLocalJson(userData);
    final nextPage = current.page + 1;

    final result = await getWishlist(
      user.id,
      page: nextPage,
      limit: current.limit,
      search: current.search,
      filters: current.filters,
      orderBy: current.orderBy,
      fields: current.fields,
    );

    result.fold(
      (failure) {
        // If network failure, keep current state (dialog will handle notification)
        if (_isNetworkError(failure)) {
          emit(current.copyWith(isLoadingMore: false));
        } else {
          emit(WishlistError(failure.message ?? ''));
        }
      },
      (items) {
        emit(
          current.copyWith(
            items: [...current.items, ...items],
            page: nextPage,
            hasMore: items.length == current.limit,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onRefresh(
    RefreshWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    add(const LoadWishlistFirstPage());
  }

  Future<void> _onLoadWishlist(
    LoadWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());
    final userData = await SessionManager.getCurrentUser();

    if (userData == null) {
      emit(
        WishlistLoaded(
          items: [],
          statusMap: {},
          page: 1,
          limit: _defaultLimit,
          hasMore: false,
        ),
      );
      return;
    }

    final user = UserModel.fromLocalJson(userData);

    final result = await getWishlist(user.id);

    result.fold(
      (failure) {
        // If network failure, keep showing shimmer (dialog will handle notification)
        if (_isNetworkError(failure)) {
          emit(WishlistLoading());
        } else {
          emit(WishlistError(failure.message ?? ''));
        }
      },
      (items) {
        emit(
          WishlistLoaded(
            items: items,
            statusMap: {},
            page: 1,
            limit: items.length,
            hasMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onToggleWishlistItem(
    ToggleWishlistItem event,
    Emitter<WishlistState> emit,
  ) async {
    final currentState = state;
    final userData = await SessionManager.getCurrentUser();

    if (userData == null) {
      emit(const WishlistError('User tidak ditemukan'));
      return;
    }

    final user = UserModel.fromLocalJson(userData);

    // ✅ OPTIMISTIC UPDATE: Hapus dari list dulu sebelum API call
    if (currentState is WishlistLoaded) {
      final updatedItems = currentState.items
          .where((item) => item.item.id != event.productId)
          .toList();

      // Emit state baru dengan item yang sudah di-filter
      emit(currentState.copyWith(items: updatedItems));
    }

    // Baru call API
    final result = await toggleWishlist(user.id, event.productId);

    result.fold(
      (failure) {
        // If network failure, keep current state (dialog will handle notification)
        if (_isNetworkError(failure)) {
          // Restore previous state
          if (currentState is WishlistLoaded) {
            emit(currentState);
          }
        } else {
          // Other errors, show error and reload
          emit(WishlistError(failure.message ?? ''));
          if (currentState is WishlistLoaded) {
            add(const LoadWishlistFirstPage());
          }
        }
      },
      (isInWishlist) {
        // ✅ Success - emit toggle state untuk product detail page
        emit(
          WishlistToggled(
            isInWishlist: isInWishlist,
            productId: event.productId,
          ),
        );

        // ✅ Kalau bukan dari wishlist page, check status
        if (currentState is! WishlistLoaded) {
          add(CheckWishlistStatus(productId: event.productId));
        }
        // Kalau dari wishlist page, list udah ke-update di optimistic update
      },
    );
  }

  Future<void> _onCheckWishlistStatus(
    CheckWishlistStatus event,
    Emitter<WishlistState> emit,
  ) async {
    final userData = await SessionManager.getCurrentUser();

    if (userData == null) {
      emit(const WishlistError('User tidak ditemukan'));
      return;
    }

    final user = UserModel.fromLocalJson(userData);

    final result = await checkWishlist(user.id, event.productId);

    result.fold(
      (failure) {
        // If network failure, don't emit error (dialog will handle notification)
        if (!_isNetworkError(failure)) {
          emit(
            WishlistError(
              '⚠️ Error checking wishlist status: ${failure.message}',
            ),
          );
        }
      },
      (isInWishlist) {
        emit(WishListStatus(isInWishlist));
      },
    );
  }

  Future<void> _onBulkDeleteWishlistItems(
    BulkDeleteWishlistItems event,
    Emitter<WishlistState> emit,
  ) async {
    if (event.productIds.isEmpty) {
      emit(const WishlistError('Tidak ada item yang dipilih'));
      return;
    }

    final currentState = state;

    // ✅ OPTIMISTIC UPDATE: Hapus dari list dulu
    if (currentState is WishlistLoaded) {
      final updatedItems = currentState.items
          .where((item) => !event.productIds.contains(item.item.id))
          .toList();

      // ✅ Emit state baru dengan updated items (bisa jadi kosong)
      final newState = currentState.copyWith(items: updatedItems);

      emit(newState);
    }

    // Call API di background
    final result = await bulkDeleteWishlist(event.userId, event.productIds);

    result.fold((failure) {
      // If network failure, keep current state (dialog will handle notification)
      if (_isNetworkError(failure)) {
        // Keep the optimistically updated state
      } else {
        // Other errors, show error and reload
        emit(WishlistError(failure.message ?? 'Gagal menghapus item'));
        add(const LoadWishlistFirstPage());
      }
    }, (deletedCount) {});
  }

  void _onClearCache(ClearWishlistCache event, Emitter<WishlistState> emit) {
    emit(WishlistInitial());
  }
}
