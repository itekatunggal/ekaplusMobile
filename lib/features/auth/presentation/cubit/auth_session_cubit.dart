// lib/features/auth/presentation/cubit/auth_session_cubit.dart
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/get_user_info.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/usecases/save_login_user.dart';
import 'package:ekaplus_ekatunggal/features/member/domain/usecases/get_active_member_companies_by_user_id.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ekaplus_ekatunggal/core/utils/session_manager.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'auth_session_state.dart';

class AuthSessionCubit extends Cubit<AuthSessionState> {
  final SaveLoginUser saveLoginUser;
  final GetUserInfo getUserInfo;
  final GetActiveMemberCompaniesByUserId getActiveMemberCompaniesByUserId;

  AuthSessionCubit({
    required this.saveLoginUser,
    required this.getUserInfo,
    required this.getActiveMemberCompaniesByUserId,
  })
    : super(AuthSessionInitial());

  Future<UserStatus> _resolveUserStatus() async {
    try {
      final result = await getActiveMemberCompaniesByUserId.execute();
      return result.fold(
        (_) => UserStatus.loggedIn,
        (companies) =>
            companies.isNotEmpty ? UserStatus.member : UserStatus.loggedIn,
      );
    } catch (_) {
      return UserStatus.loggedIn;
    }
  }

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

      final status = await _resolveUserStatus();
      emit(AuthSessionAuthenticated(user: user, status: status));
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
      (user) async {
        final status = await _resolveUserStatus();
        emit(AuthSessionAuthenticated(user: user, status: status));
      },
    );
  }

  Future<void> login(User user) async {
    final status = await _resolveUserStatus();
    emit(AuthSessionAuthenticated(user: user, status: status));
  }

  Future<void> logout() async {
    await SessionManager.clearSession();
    emit(const AuthSessionGuest());
  }

  Future<void> updateUser(User updatedUser) async {
    final userMap = (updatedUser as UserModel).toJson();
    await SessionManager.saveUser(userMap);

    final status = await _resolveUserStatus();
    emit(AuthSessionAuthenticated(user: updatedUser, status: status));
  }
}
