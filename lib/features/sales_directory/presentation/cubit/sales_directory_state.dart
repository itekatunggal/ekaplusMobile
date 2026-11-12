import 'package:ekaplus_ekatunggal/features/sales_directory/domain/entities/sales_profile.dart';
import 'package:equatable/equatable.dart';

enum SalesDirectoryStatus { initial, loading, ready, error }

class SalesDirectoryState extends Equatable {
  const SalesDirectoryState({
    this.status = SalesDirectoryStatus.initial,
    this.branchId,
    this.profiles = const [],
    this.availablePositions = const [],
    this.query = '',
    this.position,
    this.message,
  });

  final SalesDirectoryStatus status;
  final int? branchId;
  final List<SalesProfile> profiles;
  final List<String> availablePositions;
  final String query;
  final String? position;
  final String? message;

  @override
  List<Object?> get props => [
    status,
    branchId,
    profiles,
    availablePositions,
    query,
    position,
    message,
  ];
}
