import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekaplus_ekatunggal/constant.dart';
import 'package:ekaplus_ekatunggal/features/article/domain/entities/article.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.compact = false,
  });

  final Article article;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Buka artikel ${article.title}',
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: compact ? 244 : double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Cover(article: article, height: 88),
                  _Text(article, compact: true),
                ],
              )
            : Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: _Cover(article: article, height: 126),
                  ),
                  Expanded(child: _Text(article, compact: false)),
                ],
              ),
      ),
    ),
  );
}

class _Cover extends StatelessWidget {
  const _Cover({required this.article, required this.height});

  final Article article;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF334155), Color(0xFF64748B)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.article_outlined, color: Colors.white, size: 34),
    );
    final image = article.coverImage?.trim() ?? '';
    if (image.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: image,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}

class _Text extends StatelessWidget {
  const _Text(this.article, {required this.compact});

  final Article article;
  final bool compact;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          article.isDemo ? 'DEMO • ${article.category}' : article.category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.primaryColor,
            fontSize: 7.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          article.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 10.5,
            height: 1.25,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          article.summary,
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 8.5),
        ),
        if (article.publishedAt != null) ...[
          const SizedBox(height: 2),
          Text(
            DateFormat('d MMM yyyy', 'id_ID').format(article.publishedAt!),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 7.5),
          ),
        ],
      ],
    ),
  );
}
