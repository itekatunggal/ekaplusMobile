import 'package:equatable/equatable.dart';

class Article extends Equatable {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.status,
    required this.category,
    this.coverImage,
    this.publishedAt,
    this.author,
    this.isDemo = false,
  });
  final String id;
  final String title;
  final String summary;
  final String content;
  final String status;
  final String category;
  final String? coverImage;
  final DateTime? publishedAt;
  final String? author;
  final bool isDemo;

  @override
  List<Object?> get props => [
    id,
    title,
    summary,
    content,
    status,
    category,
    coverImage,
    publishedAt,
    author,
    isDemo,
  ];
}
