import 'package:equatable/equatable.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class PhoneCheckSuccess extends AuthState {
  final bool exists;
  const PhoneCheckSuccess(this.exists);

  @override
  List<Object> get props => [exists];
}

class PhoneCheckError extends AuthState {
  final String message;
  const PhoneCheckError(this.message);

  @override
  List<Object> get props => [message];
}

class PhoneExistsState extends AuthState {
  final bool exists;
  const PhoneExistsState(this.exists);

  @override
  List<Object> get props => [exists];
}

class PhoneNotFoundError extends AuthState {
  final String message;
  const PhoneNotFoundError(this.message);

  @override
  List<Object> get props => [message];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class OtpRequestSuccess extends AuthState {
  final String otp;
  final String phone;
  const OtpRequestSuccess({required this.otp, required this.phone});

  @override
  List<Object> get props => [otp, phone];
}

class OtpRequestError extends AuthState {
  final String message;
  const OtpRequestError(this.message);

  @override
  List<Object> get props => [message];
}

class OtpVerificationSuccess extends AuthState {
  final String phone;
  const OtpVerificationSuccess(this.phone);

  @override
  List<Object> get props => [phone];
}

class OtpVerificationError extends AuthState {
  final String message;
  const OtpVerificationError(this.message);

  @override
  List<Object> get props => [message];
}

class RegisterSuccess extends AuthState {
  final User user;
  const RegisterSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class RegisterError extends AuthState {
  final String message;
  const RegisterError(this.message);

  @override
  List<Object> get props => [message];
}

class LoginSuccess extends AuthState {
  final User user;
  const LoginSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class LoginError extends AuthState {
  final String message;
  const LoginError(this.message);

  @override
  List<Object> get props => [message];
}

class LoginWithGoogleSuccess extends AuthState {
  final User user;
  const LoginWithGoogleSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class LoginWithGoogleError extends AuthState {
  final String message;
  const LoginWithGoogleError(this.message);

  @override
  List<Object> get props => [message];
}

class ProfilePictureUpdateSuccess extends AuthState {
  final User user;
  const ProfilePictureUpdateSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class ProfilePictureUpdateError extends AuthState {
  final String message;
  const ProfilePictureUpdateError(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordCheckSuccess extends AuthState {
  final bool valid;
  const PasswordCheckSuccess(this.valid);

  @override
  List<Object> get props => [valid];
}

class PasswordChangeSuccess extends AuthState {}

class PasswordChangeError extends AuthState {
  final String message;
  const PasswordChangeError(this.message);

  @override
  List<Object> get props => [message];
}
