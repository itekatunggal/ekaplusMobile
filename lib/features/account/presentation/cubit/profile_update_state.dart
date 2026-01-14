// lib/features/account/presentation/cubit/profile_update_state.dart
part of 'profile_update_cubit.dart';

abstract class ProfileUpdateState extends Equatable {
  const ProfileUpdateState();

  @override
  List<Object?> get props => [];
}

class ProfileUpdateInitial extends ProfileUpdateState {}

class ProfileUpdateLoading extends ProfileUpdateState {}

class ProfileUpdateSuccess extends ProfileUpdateState {
  final User user;
  final String message;

  const ProfileUpdateSuccess(this.user, this.message);

  @override
  List<Object?> get props => [user, message];
}

class ProfileUpdateAwaitingVerification extends ProfileUpdateState {
  final String message;
  final String? pendingPhone;
  final String? pendingEmail;

  const ProfileUpdateAwaitingVerification({
    required this.message,
    this.pendingPhone,
    this.pendingEmail,
  });

  @override
  List<Object?> get props => [message, pendingPhone, pendingEmail];
}

class ProfileUpdateError extends ProfileUpdateState {
  final String message;

  const ProfileUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}