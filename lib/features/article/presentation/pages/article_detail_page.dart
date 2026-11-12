import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/core/shared_widgets/custom_header.dart';
import 'package:ekaplus_ekatunggal/features/article/domain/entities/article.dart';
import 'package:ekaplus_ekatunggal/features/article/domain/repositories/article_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArticleDetailResolverPage extends StatelessWidget {
  const ArticleDetailResolverPage({
    super.key,
    required this.id,
    required this.repository,
    this.initial,
  });

  final String id;
  final ArticleRepository repository;
  final Article? initial;

  @override
  Widget build(BuildContext context) {
    if (initial != null) return ArticleDetailPage(article: initial!);
    return FutureBuilder<Article?>(
      future: repository.getArticleById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }
        return snapshot.data == null
            ? const Scaffold(
                body: Center(child: Text('Artikel tidak tersedia')),
              )
            : ArticleDetailPage(article: snapshot.data!);
      },
    );
  }
}

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({super.key, required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) => CustomHeaderScaffold(
    title: 'Detail Artikel',
    showBackButton: true,
    backgroundColor: const Color(0xFFF6F7F9),
    body: ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        Container(
          height: 190,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF334155), Color(0xFF64748B)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.article_outlined,
            color: Colors.white,
            size: 54,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: _detailDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.isDemo
                    ? 'KONTEN DEMO • ${article.category.toUpperCase()}'
                    : article.category.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                article.title,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (article.publishedAt != null || article.author != null) ...[
                const SizedBox(height: 8),
                Text(
                  [
                    if (article.author != null) article.author!,
                    if (article.publishedAt != null)
                      DateFormat(
                        'd MMMM yyyy',
                        'id_ID',
                      ).format(article.publishedAt!),
                  ].join(' • '),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                article.summary,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
              const Divider(height: 28),
              Text(
                article.content,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

const _detailDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(18)),
  border: Border.fromBorderSide(BorderSide(color: Color(0xFFF1F5F9))),
  boxShadow: [
    BoxShadow(color: Color(0x120F172A), blurRadius: 20, offset: Offset(0, 6)),
  ],
);
