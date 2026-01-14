// lib/features/auth/domain/usecases/change_password.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository repository;

  ChangePassword(this.repository);

  Future<Either<Failure, User>> call({
    required String newPassword,
    required String oldPassword, // Optional: null if forgot password flow
  }) async {
    return await repository.changePassword(
      newPassword: newPassword,
      oldPassword: oldPassword,
    );
  }
}
