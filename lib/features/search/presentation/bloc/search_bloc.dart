// lib/features/search/presentation/bloc/search_bloc.dart

import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/usecases/get_all_category.dart';
import 'package:ekaplus_ekatunggal/features/product/domain/usecases/get_all_product.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:ekaplus_ekatunggal/features/product/domain/entities/product.dart';
import 'package:ekaplus_ekatunggal/features/category/domain/entities/category.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final GetAllProduct getAllProduct;
  final GetAllCategory getAllCategory;
  List<Product> _allProducts = [];
  List<Category> _allCategories = [];

  SearchBloc({required this.getAllProduct, required this.getAllCategory})
    : super(const SearchStateLoading()) {
    on<SearchEventInitial>(_onInitial);
    on<SearchEventQueryChanged>(_onQueryChanged);
    on<SearchEventClearQuery>(_onClearQuery);
  }

  bool _isNetworkError(Failure failure) {
    return failure is NetworkFailure ||
        failure is TimeoutFailure ||
        (failure is ServerFailure &&
            (failure.statusCode == null || failure.statusCode! >= 500));
  }

  Future<void> _onInitial(
    SearchEventInitial event,
    Emitter<SearchState> emit,
  ) async {
    try {
      emit(const SearchStateLoading());

      final result = await getAllProduct.execute(
        filters: [
          ["hot_deals", "=", "1"],
        ],
      );

      result.fold(
        (failure) {
          // If network failure, keep showing loading (dialog will handle notification)
          if (!_isNetworkError(failure)) {
            emit(SearchStateError(failure.message ?? 'Cannot get products'));
          }
        },
        (products) {
          _allProducts = products;
        },
      );

      Either<Failure, List<Category>> resultGetAllCategory =
          await getAllCategory.execute(1);

      resultGetAllCategory.fold(
        (l) {
          // If network failure, keep showing loading (dialog will handle notification)
          if (!_isNetworkError(l)) {
            emit(SearchStateError('Cannot get all Categorys'));
          }
        },
        (r) {
          _allCategories = r;
        },
      );

      emit(
        SearchStateInitial(hotDeals: _allProducts, categories: _allCategories),
      );
    } catch (e) {
      emit(SearchStateError('Gagal memuat data: ${e.toString()}'));
    }
  }

  Future<void> _onQueryChanged(
    SearchEventQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(
        SearchStateInitial(hotDeals: _allProducts, categories: _allCategories),
      );
      return;
    }

    final result = await getAllProduct.execute(
      page: 1,
      search: query.toLowerCase(),
    );

    result.fold(
      (failure) {
        // If network failure, keep showing loading (dialog will handle notification)
        if (_isNetworkError(failure)) {
          emit(const SearchStateLoading());
        } else {
          emit(SearchStateEmpty(failure.message ?? 'Cannot get products'));
        }
      },
      (products) {
        emit(SearchStateLoaded(query: query, results: products));
      },
    );
  }

  Future<void> _onClearQuery(
    SearchEventClearQuery event,
    Emitter<SearchState> emit,
  ) async {
    final hotDeals = _allProducts
        .where((product) => product.isHotDeals == true)
        .take(4)
        .toList();

    emit(SearchStateInitial(hotDeals: hotDeals, categories: _allCategories));
  }
}
