import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_all_product.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_hot_deals.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_product.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProduct getAllProduct;
  final GetProduct getProduct;
  final GetHotDeals getHotDeals;

  static const int _defaultLimit = 20;

  // Helper method to check if error is network-related
  bool _isNetworkError(Failure failure) {
    final errorMessage = failure.message?.toLowerCase() ?? '';
    return failure is NetworkFailure ||
        errorMessage.contains('socketexception') ||
        errorMessage.contains('no connection') ||
        errorMessage.contains('failed host lookup');
  }

  ProductBloc({
    required this.getAllProduct,
    required this.getProduct,
    required this.getHotDeals,
  }) : super(const ProductInitial()) {
    on<ProductEventLoadFirstPage>(_onLoadFirstPage);
    on<ProductEventLoadNextPage>(_onLoadNextPage);
    on<ProductEventRefresh>(_onRefresh);
    on<ProductEventGetDetail>(_onGetDetail);
    on<ProductEventGetVariant>(_onGetVariant);
    on<ProductEventGetHotDeals>(_onGetHotDeals);
    on<ProductEventClearCache>(_onClearCache);
  }

  Future<void> _onLoadFirstPage(
    ProductEventLoadFirstPage event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductListLoading());

    final limit = event.limit ?? _defaultLimit;

    final result = await getAllProduct.execute(
      page: 1,
      limit: limit,
      search: event.search,
      filters: event.filters,
      orderBy: event.orderBy,
      fields: event.fields,
    );

    result.fold((failure) {
      // If network failure, keep showing shimmer (dialog will handle notification)
      if (_isNetworkError(failure)) {
        emit(const ProductListLoading());
      } else {
        emit(ProductError(failure.message ?? 'Cannot get products'));
      }
    }, (products) {
      emit(
        ProductListLoaded(
          products: products,
          page: 1,
          limit: limit,
          hasMore: products.length == limit,
          search: event.search,
          filters: event.filters,
          orderBy: event.orderBy,
          fields: event.fields,
        ),
      );
    });
  }

  Future<void> _onLoadNextPage(
    ProductEventLoadNextPage event,
    Emitter<ProductState> emit,
  ) async {
    final current = state;
    if (current is! ProductListLoaded) return;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.page + 1;

    final result = await getAllProduct.execute(
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
          emit(ProductError(failure.message ?? 'Cannot load more products'));
        }
      },
      (products) {
        emit(
          current.copyWith(
            products: [...current.products, ...products],
            page: nextPage,
            hasMore: products.length == current.limit,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  Future<void> _onRefresh(
    ProductEventRefresh event,
    Emitter<ProductState> emit,
  ) async {
    add(const ProductEventLoadFirstPage());
  }

  Future<void> _onGetDetail(
    ProductEventGetDetail event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductDetailLoading());

    final result = await getProduct.execute(event.productId);

    result.fold(
      (failure) {
        // If network failure, keep showing shimmer (dialog will handle notification)
        if (_isNetworkError(failure)) {
          emit(const ProductDetailLoading());
        } else {
          emit(ProductError(failure.message ?? 'Cannot get product detail'));
        }
      },
      (product) => emit(ProductDetailLoaded(product)),
    );
  }

  Future<void> _onGetVariant(
    ProductEventGetVariant event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductVariantLoading());
  }

  Future<void> _onGetHotDeals(
    ProductEventGetHotDeals event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductListLoading());

    final result = await getHotDeals.execute();

    result.fold(
      (failure) {
        // If network failure, keep showing shimmer (dialog will handle notification)
        if (_isNetworkError(failure)) {
          emit(const ProductListLoading());
        } else {
          emit(ProductError(failure.message ?? 'Cannot get hot deals'));
        }
      },
      (products) {
        emit(
          ProductListLoaded(
            products: products,
            page: 1,
            limit: products.length,
            hasMore: false,
          ),
        );
      },
    );
  }

  void _onClearCache(ProductEventClearCache event, Emitter<ProductState> emit) {
    emit(const ProductInitial());
  }
}
