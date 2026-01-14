// lib/features/auth/domain/usecases/update_full_name.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class GetUserInfo {
  final AuthRepository repository;

  GetUserInfo(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.getUserInfo();
  }
}
