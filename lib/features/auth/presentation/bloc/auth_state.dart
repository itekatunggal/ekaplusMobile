import 'package:equatable/equatable.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/social_auth_result.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

enum AuthOperation { other, manualLogin, googleLogin, appleLogin, completion }

class AuthLoading extends AuthState {
  final AuthOperation operation;

  const AuthLoading([this.operation = AuthOperation.other]);

  @override
  List<Object> get props => [operation];
}

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
  final String? code;
  const LoginWithGoogleError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class LoginWithAppleSuccess extends AuthState {
  final User user;
  const LoginWithAppleSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class LoginWithAppleError extends AuthState {
  final String message;
  final String? code;
  const LoginWithAppleError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class SocialRegistrationRequired extends AuthState {
  final String registrationToken;
  final int expiresIn;
  final SocialPrefill prefill;
  final SocialProvider provider;

  const SocialRegistrationRequired({
    required this.registrationToken,
    required this.expiresIn,
    required this.prefill,
    required this.provider,
  });

  @override
  List<Object?> get props => [expiresIn, prefill.email, provider];

  @override
  String toString() =>
      'SocialRegistrationRequired(provider: $provider, expiresIn: $expiresIn)';
}

class SocialRegistrationCompleted extends AuthState {
  final User user;
  const SocialRegistrationCompleted(this.user);

  @override
  List<Object> get props => [user];
}

class SocialRegistrationError extends AuthState {
  final String message;
  final String? code;
  const SocialRegistrationError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
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
