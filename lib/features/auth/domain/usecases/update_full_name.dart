// lib/features/auth/domain/usecases/update_full_name.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class UpdateFullName {
  final AuthRepository repository;

  UpdateFullName(this.repository);

  Future<Either<Failure, User>> call({
    required String userId,
    required String fullName,
  }) async {
    return await repository.updateFullName(userId, fullName);
  }
}