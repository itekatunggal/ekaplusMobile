// lib/features/auth/domain/usecases/request_email_change.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class RequestEmailChange {
  final AuthRepository repository;

  RequestEmailChange(this.repository);

  Future<Either<Failure, String>> call({
    required String userId,
    required String newEmail,
    required String password,
  }) async {
    return await repository.requestEmailChange(
      newEmail: newEmail,
      password: password,
    );
  }
}
