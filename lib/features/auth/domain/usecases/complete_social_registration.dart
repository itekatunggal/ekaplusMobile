import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class CompleteSocialRegistration {
  final AuthRepository repository;

  CompleteSocialRegistration(this.repository);

  Future<Either<Failure, User>> call({
    required String ticket,
    required String username,
    required String password,
  }) {
    return repository.completeSocialRegistration(
      ticket: ticket,
      username: username,
      password: password,
    );
  }
}
