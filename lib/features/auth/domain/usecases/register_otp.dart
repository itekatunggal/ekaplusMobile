import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class RegisterOtp {
  final AuthRepository repository;

  RegisterOtp(this.repository);

  Future<Either<Failure, String>> call(String phone) {
    return repository.registerOtp(phone);
  }
}
