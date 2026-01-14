// lib/features/auth/presentation/cubit/auth_session_state.dart

import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

enum UserStatus { guest, loggedIn, member }

abstract class AuthSessionState extends Equatable {
  const AuthSessionState();

  @override
  List<Object?> get props => [];
}

// ======================================================
// INITIAL
// ======================================================
class AuthSessionInitial extends AuthSessionState {
  const AuthSessionInitial();
}

// ======================================================
// LOADING
// ======================================================
class AuthSessionLoading extends AuthSessionState {
  const AuthSessionLoading();
}

// ======================================================
// GUEST (NOT LOGGED IN)
// ======================================================
class AuthSessionGuest extends AuthSessionState {
  const AuthSessionGuest();

  @override
  List<Object?> get props => [];
}

// ======================================================
// AUTHENTICATED
// ======================================================
class AuthSessionAuthenticated extends AuthSessionState {
  final User user;
  final UserStatus status;

  const AuthSessionAuthenticated({
    required this.user,
    this.status = UserStatus.loggedIn,
  });

  bool get isGuest => status == UserStatus.guest;
  bool get isLoggedIn => status == UserStatus.loggedIn;
  bool get isMember => status == UserStatus.member;

  @override
  List<Object?> get props => [user, status];

  AuthSessionAuthenticated copyWith({User? user, UserStatus? status}) {
    return AuthSessionAuthenticated(
      user: user ?? this.user,
      status: status ?? this.status,
    );
  }
}

// ======================================================
// ERROR
// ======================================================
class AuthSessionError extends AuthSessionState {
  final String message;

  const AuthSessionError(this.message);

  @override
  List<Object?> get props => [message];
}
