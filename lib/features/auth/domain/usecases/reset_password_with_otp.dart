// lib/features/auth/domain/usecases/reset_password_with_otp.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordWithOtp {
  final AuthRepository repository;

  ResetPasswordWithOtp(this.repository);

  Future<Either<Failure, User>> call({
    required String phone,
    required String newPassword,
  }) async {
    return await repository.resetPasswordWithOtp(
      phone: phone,
      newPassword: newPassword,
    );
  }
}