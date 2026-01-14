// lib/features/auth/presentation/cubit/auth_session_cubit.dart
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/get_user_info.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/save_login_user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'auth_session_state.dart';

class AuthSessionCubit extends Cubit<AuthSessionState> {
  final SaveLoginUser saveLoginUser;
  final GetUserInfo getUserInfo;
  AuthSessionCubit({required this.saveLoginUser, required this.getUserInfo})
    : super(AuthSessionInitial());

  Future<void> checkSession() async {
    emit(AuthSessionLoading());

    try {
      final isLoggedIn = await SessionManager.isLoggedIn();
      if (!isLoggedIn) {
        emit(const AuthSessionGuest());
        return;
      }

      final userData = await SessionManager.getCurrentUser();

      if (userData == null) {
        emit(const AuthSessionGuest());
        return;
      }

      final user = UserModel.fromLocalJson(userData);

      emit(AuthSessionAuthenticated(user: user, status: UserStatus.loggedIn));
    } catch (_) {
      emit(const AuthSessionGuest());
    }
  }

  Future<void> refreshUser() async {
    final result = await getUserInfo();

    result.fold(
      (f) {
        checkSession();
      },
      (user) {
        emit(AuthSessionAuthenticated(user: user, status: UserStatus.loggedIn));
      },
    );
  }

  Future<void> login(User user) async {
    emit(AuthSessionAuthenticated(user: user, status: UserStatus.loggedIn));
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
    emit(const AuthSessionGuest());
  }

  Future<void> updateUser(User updatedUser) async {
    final userMap = (updatedUser as UserModel).toJson();
    await SessionManager.saveUser(userMap);

    emit(
      AuthSessionAuthenticated(user: updatedUser, status: UserStatus.loggedIn),
    );
  }
}
