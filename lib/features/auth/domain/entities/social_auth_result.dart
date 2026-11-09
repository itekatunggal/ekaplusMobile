import 'package:ekaplus_ekatunggal/features/auth/domain/entities/user.dart';

enum SocialProvider { google, apple }

class SocialPrefill {
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? profilePic;

  const SocialPrefill({
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.profilePic,
  });

  factory SocialPrefill.fromJson(Map<String, dynamic>? json) {
    return SocialPrefill(
      email: json?['email']?.toString(),
      firstName: json?['first_name']?.toString(),
      lastName: json?['last_name']?.toString(),
      fullName: json?['full_name']?.toString(),
      profilePic: json?['profile_pic']?.toString(),
    );
  }
}

sealed class SocialAuthResult {
  const SocialAuthResult();
}

class SocialLoginAuthenticated extends SocialAuthResult {
  final User user;

  const SocialLoginAuthenticated(this.user);
}

class SocialRegistrationPending extends SocialAuthResult {
  final String registrationToken;
  final int expiresIn;
  final SocialPrefill prefill;
  final SocialProvider provider;

  const SocialRegistrationPending({
    required this.registrationToken,
    required this.expiresIn,
    required this.prefill,
    required this.provider,
  });

  @override
  String toString() =>
      'SocialRegistrationPending(provider: $provider, expiresIn: $expiresIn)';
}
