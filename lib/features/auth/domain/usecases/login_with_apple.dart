import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/social_auth_result.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class LoginWithApple {
  final AuthRepository repository;

  LoginWithApple(this.repository);

  Future<Either<Failure, SocialAuthResult>> call(String identityToken) {
    return repository.loginWithApple(identityToken);
  }
}
