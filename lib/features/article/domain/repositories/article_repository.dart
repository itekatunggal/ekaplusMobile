import 'package:ekaplus_ekatunggal/features/article/domain/entities/article.dart';

abstract class ArticleRepository {
  Future<List<Article>> getArticles({String? query, String? category});
  Future<Article?> getArticleById(String id);
}
