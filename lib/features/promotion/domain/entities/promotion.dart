import 'package:equatable/equatable.dart';

class Promotion extends Equatable {
  const Promotion({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.status,
    this.coverImage,
    this.startAt,
    this.endAt,
    this.branchId,
    this.targetAudience,
    this.isDemo = false,
  });

  final String id;
  final String title;
  final String summary;
  final String content;
  final String status;
  final String? coverImage;
  final DateTime? startAt;
  final DateTime? endAt;
  final int? branchId;
  final String? targetAudience;
  final bool isDemo;

  bool isActiveAt(DateTime now) {
    if (status.toLowerCase() != 'active') return false;
    if (startAt != null && now.isBefore(startAt!)) return false;
    if (endAt != null && now.isAfter(endAt!)) return false;
    return true;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    summary,
    content,
    status,
    coverImage,
    startAt,
    endAt,
    branchId,
    targetAudience,
    isDemo,
  ];
}
