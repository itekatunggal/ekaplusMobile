// lib/features/category/presentation/bloc/category_event.dart

part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class CategoryEventGetAllCategories extends CategoryEvent {
  final int page;

  const CategoryEventGetAllCategories(this.page);

  @override
  List<Object> get props => [];
}

class CategoryEventGetDetailCategory extends CategoryEvent {
  final String categoryId;

  const CategoryEventGetDetailCategory(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

class CategoryEventGetByType extends CategoryEvent {
  const CategoryEventGetByType();

  @override
  List<Object> get props => [];
}
