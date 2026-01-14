// lib/features/auth/domain/usecases/verify_email_change.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class VerifyEmailChange {
  final AuthRepository repository;

  VerifyEmailChange(this.repository);

  Future<Either<Failure, User>> call({
    required String userId,
    required String newEmail,
    required String verificationCode,
  }) async {
    return await repository.verifyEmailChange(
      userId: userId,
      newEmail: newEmail,
      verificationCode: verificationCode,
    );
  }
}