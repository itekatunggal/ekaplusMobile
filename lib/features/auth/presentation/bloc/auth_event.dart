import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckPhoneEvent extends AuthEvent {
  final String phone;

  const CheckPhoneEvent(this.phone);

  @override
  List<Object> get props => [phone];
}

class CheckPasswordEvent extends AuthEvent {
  final String password;
  const CheckPasswordEvent(this.password);

  @override
  List<Object> get props => [password];
}

class ChangePasswordEvent extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [oldPassword, newPassword];
}

class CheckPhoneExistsEvent extends AuthEvent {
  final String phone;

  const CheckPhoneExistsEvent(this.phone);

  @override
  List<Object> get props => [phone];
}

class RequestOtpEvent extends AuthEvent {
  final String phone;

  const RequestOtpEvent(this.phone);

  @override
  List<Object> get props => [phone];
}

class RegisterOtpEvent extends AuthEvent {
  final String phone;

  const RegisterOtpEvent(this.phone);

  @override
  List<Object> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  final String method;

  const VerifyOtpEvent(this.phone, this.otp, this.method);

  @override
  List<Object> get props => [phone, otp];
}

class RegisterUserEvent extends AuthEvent {
  final String phone;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String gender;
  final DateTime dateOfBirth;
  final String birthPlace;

  const RegisterUserEvent({
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.gender,
    required this.dateOfBirth,
    required this.birthPlace,
  });

  @override
  List<Object?> get props => [
    phone,
    firstName,
    lastName,
    username,
    email,
    password,
    gender,
    dateOfBirth,
    birthPlace,
  ];
}

class LoginUserEvent extends AuthEvent {
  final String identifier;
  final String password;

  const LoginUserEvent({required this.identifier, required this.password});

  @override
  List<Object> get props => [identifier, password];
}

class LoginWithGoogleEvent extends AuthEvent {
  const LoginWithGoogleEvent();

  @override
  List<Object> get props => [];
}

class UpdateProfilePictureEvent extends AuthEvent {
  final String userId;
  final String? profilePicPath;
  final String? bgColor;

  const UpdateProfilePictureEvent({
    required this.userId,
    required this.profilePicPath,
    this.bgColor,
  });

  @override
  List<Object?> get props => [userId, profilePicPath, bgColor];
}

class ResetAuthEvent extends AuthEvent {}
