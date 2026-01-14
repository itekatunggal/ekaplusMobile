// lib/features/auth/domain/usecases/update_profile_picture.dart
import 'package:dartz/dartz.dart';
import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfilePicture {
  final AuthRepository repository;

  UpdateProfilePicture(this.repository);

  Future<Either<Failure, User>> call(String userId, String? profilePicPath, String? bgColor,) async {
    return await repository.updateProfilePicture(userId, profilePicPath, bgColor);
  }
}