// lib/features/search/presentation/bloc/search_event.dart
part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchEventInitial extends SearchEvent {
  const SearchEventInitial();
}

class SearchEventQueryChanged extends SearchEvent {
  final String query;
  final List<List<dynamic>> filters;

  const SearchEventQueryChanged(this.query, {this.filters = const []});

  @override
  List<Object?> get props => [query, filters];
}

class SearchEventClearQuery extends SearchEvent {
  const SearchEventClearQuery();
}
