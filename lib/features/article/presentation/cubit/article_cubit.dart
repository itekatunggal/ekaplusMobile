import 'package:ekaplus_ekatunggal/features/article/domain/entities/article.dart';
import 'package:ekaplus_ekatunggal/features/article/domain/repositories/article_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ArticleStatus { initial, loading, ready, error }

class ArticleState extends Equatable {
  const ArticleState({
    this.status = ArticleStatus.initial,
    this.items = const [],
    this.categories = const [],
    this.query = '',
    this.category,
    this.message,
  });
  final ArticleStatus status;
  final List<Article> items;
  final List<String> categories;
  final String query;
  final String? category;
  final String? message;
  @override
  List<Object?> get props => [
    status,
    items,
    categories,
    query,
    category,
    message,
  ];
}

class ArticleCubit extends Cubit<ArticleState> {
  ArticleCubit(this._repository) : super(const ArticleState());
  final ArticleRepository _repository;
  int _version = 0;

  Future<void> load({String query = '', String? category}) async {
    final version = ++_version;
    emit(
      ArticleState(
        status: ArticleStatus.loading,
        items: state.items,
        categories: state.categories,
        query: query,
        category: category,
      ),
    );
    try {
      final all = await _repository.getArticles();
      final categories = all.map((item) => item.category).toSet().toList()
        ..sort();
      final items = query.trim().isEmpty && (category?.isEmpty ?? true)
          ? all
          : await _repository.getArticles(query: query, category: category);
      if (version != _version || isClosed) return;
      emit(
        ArticleState(
          status: ArticleStatus.ready,
          items: items,
          categories: categories,
          query: query,
          category: category,
        ),
      );
    } catch (_) {
      if (version != _version || isClosed) return;
      emit(
        ArticleState(
          status: ArticleStatus.error,
          query: query,
          category: category,
          message: 'Artikel belum dapat dimuat',
        ),
      );
    }
  }
}
