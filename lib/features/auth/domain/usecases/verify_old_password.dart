// lib/features/auth/domain/usecases/verify_old_password.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class VerifyOldPassword {
  final AuthRepository repository;

  VerifyOldPassword(this.repository);

  Future<Either<Failure, bool>> call({
    required String userId,
    required String oldPassword,
  }) async {
    return await repository.verifyOldPassword(
      userId: userId,
      oldPassword: oldPassword,
    );
  }
}