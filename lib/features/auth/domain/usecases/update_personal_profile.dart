import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class UpdatePersonalProfile {
  const UpdatePersonalProfile(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, User>> call({
    required String fullName,
    required String gender,
    required String placeOfBirth,
    required DateTime? dateOfBirth,
  }) {
    return repository.updatePersonalProfile(
      fullName: fullName,
      gender: gender,
      placeOfBirth: placeOfBirth,
      dateOfBirth: dateOfBirth,
    );
  }
}
