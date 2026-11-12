import 'package:ekaplus_ekatunggal/features/article/domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.summary,
    required super.content,
    required super.status,
    required super.category,
    super.coverImage,
    super.publishedAt,
    super.author,
    super.isDemo,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    summary: json['summary']?.toString() ?? '',
    content: json['content']?.toString() ?? '',
    status: json['status']?.toString() ?? '',
    category: json['category']?.toString() ?? '',
    coverImage: _text(json['cover_image']),
    publishedAt: DateTime.tryParse(json['published_at']?.toString() ?? ''),
    author: _text(json['author']),
    isDemo: json['is_demo'] == true || json['is_demo'] == 1,
  );

  static String? _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
