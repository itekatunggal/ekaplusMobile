// lib/features/auth/domain/usecases/check_password.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class CheckPassword {
  final AuthRepository repository;

  CheckPassword(this.repository);

  Future<Either<Failure, bool>> call({required String password}) async {
    return await repository.checkPassword(password: password);
  }
}
