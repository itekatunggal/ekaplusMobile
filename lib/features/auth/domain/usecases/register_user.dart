// lib/features/auth/domain/usecases/register_user.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser(this.repository);

  Future<Either<Failure, User>> call(RegisterUserParams params) {
    return repository.registerUser(params);
  }
}

class RegisterUserParams {
  final String phone;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String gender;
  final DateTime dateOfBirth;
  final String birthPlace;

  RegisterUserParams({
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.gender,
    required this.dateOfBirth,
    required this.birthPlace,
  });
}
