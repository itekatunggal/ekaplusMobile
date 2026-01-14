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

  const SearchEventQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchEventClearQuery extends SearchEvent {
  const SearchEventClearQuery();
}