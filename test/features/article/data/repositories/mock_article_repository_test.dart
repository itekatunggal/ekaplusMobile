import 'package:ekaplus_ekatunggal/features/article/data/repositories/mock_article_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockArticleRepository repository;

  setUp(() => repository = MockArticleRepository());

  test(
    'hanya mengembalikan artikel published dan terbaru lebih dulu',
    () async {
      final articles = await repository.getArticles();

      expect(articles, hasLength(2));
      expect(articles.first.id, 'article-demo-1');
      expect(
        articles.map((item) => item.id),
        isNot(contains('article-draft-demo')),
      );
    },
  );

  test('mendukung filter kategori dan menyembunyikan detail draft', () async {
    final result = await repository.getArticles(category: 'Informasi');
    final draft = await repository.getArticleById('article-draft-demo');

    expect(result, hasLength(1));
    expect(result.single.category, 'Informasi');
    expect(draft, isNull);
  });
}
