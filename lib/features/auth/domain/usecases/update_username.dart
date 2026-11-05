import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class UpdateUsername {
  final AuthRepository repository;

  UpdateUsername(this.repository);

  Future<Either<Failure, User>> call({
    required String userId,
    required String username,
  }) async {
    return await repository.updateUsername(userId, username);
  }
}
