// lib/features/auth/domain/entities/update_profile_request.dart
class UpdateProfileRequest {
  final String? fullName;
  final String? phone;
  final String? email;
  final String? password; // Required for phone/email changes
  final String? verificationCode; // For OTP verification

  UpdateProfileRequest({
    this.fullName,
    this.phone,
    this.email,
    this.password,
    this.verificationCode,
  });
}