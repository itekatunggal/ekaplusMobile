// lib/features/auth/domain/usecases/check_phone_exists.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class CheckPhoneExists {
  final AuthRepository repository;

  CheckPhoneExists(this.repository);

  Future<Either<Failure, bool>> call(String phone) async {
    return await repository.checkPhoneExists(phone);
  }
}