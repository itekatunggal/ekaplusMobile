// lib/features/auth/domain/usecases/login_user.dart

import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';

import 'package:ekaplus_ekatunggal/features/auth/domain/repositories/auth_repository.dart';

class SaveLoginUser {
  final AuthRepository repository;

  SaveLoginUser(this.repository);

  Future<void> call(UserModel user) async {
    return await repository.saveLoginUser(user: user);
  }
}
