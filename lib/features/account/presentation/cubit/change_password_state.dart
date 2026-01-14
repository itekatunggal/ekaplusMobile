// lib/features/account/presentation/cubit/change_password_state.dart
part of 'change_password_cubit.dart';

abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordLoading extends ChangePasswordState {}

class ChangePasswordOldVerified extends ChangePasswordState {}

class ChangePasswordSuccess extends ChangePasswordState {
  final User user;
  final String message;

  const ChangePasswordSuccess(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

class ChangePasswordError extends ChangePasswordState {
  final String message;

  const ChangePasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
