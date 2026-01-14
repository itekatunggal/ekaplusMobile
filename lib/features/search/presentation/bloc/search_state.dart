// lib/features/search/presentation/bloc/search_state.dart
part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchStateInitial extends SearchState {
  final List<Product> hotDeals;
  final List<Category> categories;

  const SearchStateInitial({
    required this.hotDeals,
    required this.categories,
  });

  @override
  List<Object?> get props => [hotDeals, categories];
}

class SearchStateLoading extends SearchState {
  const SearchStateLoading();
}

class SearchStateLoaded extends SearchState {
  final String query;
  final List<Product> results;

  const SearchStateLoaded({
    required this.query,
    required this.results,
  });

  @override
  List<Object?> get props => [query, results];
}

class SearchStateEmpty extends SearchState {
  final String query;

  const SearchStateEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchStateError extends SearchState {
  final String message;

  const SearchStateError(this.message);

  @override
  List<Object?> get props => [message];
}