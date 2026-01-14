// lib/features/category/presentation/bloc/category_state.dart

part of 'category_bloc.dart';

abstract class CategoryState extends Equatable {}

class CategoryStateEmpty extends CategoryState {
  @override
  List<Object?> get props => [];
}

class CategoryStateLoading extends CategoryState {
  @override
  List<Object?> get props => [];
}

class CategoryStateError extends CategoryState {
  final String message;

  CategoryStateError(this.message);
  @override
  List<Object?> get props => [message];
}

class CategoryStateLoadedAllCategory extends CategoryState {
  final List<Category> allCategory;

  CategoryStateLoadedAllCategory(this.allCategory);
  @override
  List<Object?> get props => [allCategory];
}

class CategoryStateLoadedCategoryByType extends CategoryState {
  final List<CategoryGroupEntity> allCategory;

  CategoryStateLoadedCategoryByType(this.allCategory);
  @override
  List<Object?> get props => [allCategory];
}

class CategoryStateLoadedCategory extends CategoryState {
  final Category detailCategory;

  CategoryStateLoadedCategory(this.detailCategory);
  @override
  List<Object?> get props => [detailCategory];
}
