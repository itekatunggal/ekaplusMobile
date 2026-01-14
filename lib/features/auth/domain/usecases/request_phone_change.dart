// lib/features/auth/domain/usecases/request_phone_change.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class RequestPhoneChange {
  final AuthRepository repository;

  RequestPhoneChange(this.repository);

  Future<Either<Failure, String>> call({
    required String userId,
    required String newPhone,
    required String password,
  }) async {
    return await repository.requestPhoneChange(
      userId: userId,
      newPhone: newPhone,
      password: password,
    );
  }
}