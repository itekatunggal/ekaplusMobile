import 'package:ekaplus_ekatunggal/features/article/data/models/article_model.dart';
import 'package:ekaplus_ekatunggal/features/article/domain/entities/article.dart';
import 'package:ekaplus_ekatunggal/features/article/domain/repositories/article_repository.dart';

class MockArticleRepository implements ArticleRepository {
  static final _fixtures = <Article>[
    ArticleModel(
      id: 'article-demo-1',
      title: 'Berita Ekatunggal akan hadir di sini',
      summary: 'Pratinjau area berita dan informasi perusahaan.',
      content:
          'Ini adalah artikel demo. Berita resmi perusahaan akan ditampilkan setelah konten tersedia.',
      status: 'published',
      category: 'Berita',
      publishedAt: DateTime(2026, 11, 1),
      author: 'Ekatunggal',
      isDemo: true,
    ),
    ArticleModel(
      id: 'article-demo-2',
      title: 'Informasi layanan untuk pelanggan',
      summary: 'Contoh tata letak artikel informatif EKAPLUS.',
      content:
          'Konten ini hanya digunakan untuk pratinjau. Informasi layanan resmi akan menggantikannya.',
      status: 'published',
      category: 'Informasi',
      publishedAt: DateTime(2026, 10, 20),
      author: 'Ekatunggal',
      isDemo: true,
    ),
    const ArticleModel(
      id: 'article-draft-demo',
      title: 'Artikel draft',
      summary: 'Tidak boleh tampil.',
      content: 'Fixture pengujian.',
      status: 'draft',
      category: 'Berita',
      isDemo: true,
    ),
  ];

  @override
  Future<List<Article>> getArticles({String? query, String? category}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final normalizedQuery = query?.trim().toLowerCase() ?? '';
    final normalizedCategory = category?.trim().toLowerCase() ?? '';
    final rows = _fixtures
        .where((article) {
          final published = article.status.toLowerCase() == 'published';
          final categoryMatches =
              normalizedCategory.isEmpty ||
              article.category.toLowerCase() == normalizedCategory;
          final queryMatches =
              normalizedQuery.isEmpty ||
              article.title.toLowerCase().contains(normalizedQuery) ||
              article.summary.toLowerCase().contains(normalizedQuery);
          return published && categoryMatches && queryMatches;
        })
        .toList(growable: false);
    rows.sort(
      (a, b) => (b.publishedAt ?? DateTime(1970)).compareTo(
        a.publishedAt ?? DateTime(1970),
      ),
    );
    return rows;
  }

  @override
  Future<Article?> getArticleById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    for (final article in _fixtures) {
      if (article.id == id && article.status.toLowerCase() == 'published') {
        return article;
      }
    }
    return null;
  }
}
