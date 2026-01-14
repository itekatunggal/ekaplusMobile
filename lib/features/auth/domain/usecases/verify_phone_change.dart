// lib/features/auth/domain/usecases/verify_phone_change.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class VerifyPhoneChange {
  final AuthRepository repository;

  VerifyPhoneChange(this.repository);

  Future<Either<Failure, User>> call({
    required String userId,
    required String newPhone,
    required String verificationCode,
  }) async {
    return await repository.verifyPhoneChange(
      userId: userId,
      newPhone: newPhone,
      verificationCode: verificationCode,
    );
  }
}