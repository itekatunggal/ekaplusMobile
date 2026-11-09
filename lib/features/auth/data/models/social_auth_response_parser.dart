import 'package:ekaplus_ekatunggal/core/network/network_exceptions.dart';
import 'package:ekaplus_ekatunggal/features/auth/data/models/user_model.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/social_auth_result.dart';

class ParsedSocialAuthResponse {
  final SocialAuthResult result;
  final String? accessToken;
  final String? refreshToken;

  const ParsedSocialAuthResponse({
    required this.result,
    this.accessToken,
    this.refreshToken,
  });
}

class ParsedSocialCompletionResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;

  const ParsedSocialCompletionResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });
}

class SocialAuthResponseParser {
  const SocialAuthResponseParser._();

  static ParsedSocialAuthResponse parseLogin(
    Map<String, dynamic> body, {
    required SocialProvider provider,
  }) {
    if (body['data'] is! Map) {
      throw const UnknownException(message: 'Response tidak valid');
    }
    final data = Map<String, dynamic>.from(body['data'] as Map);
    if (data['registration_required'] == true ||
        body['code'] == 'REGISTRATION_REQUIRED') {
      final registrationToken = data['registration_token']?.toString();
      if (registrationToken == null || registrationToken.isEmpty) {
        throw const UnknownException(
          message: 'Registration token tidak tersedia',
        );
      }
      final expiresIn = data['expires_in'] is int
          ? data['expires_in'] as int
          : int.tryParse(data['expires_in']?.toString() ?? '') ?? 600;
      return ParsedSocialAuthResponse(
        result: SocialRegistrationPending(
          registrationToken: registrationToken,
          expiresIn: expiresIn,
          prefill: SocialPrefill.fromJson(
            data['prefill'] is Map
                ? Map<String, dynamic>.from(data['prefill'] as Map)
                : null,
          ),
          provider: provider,
        ),
      );
    }

    final accessToken = data['access_token']?.toString();
    final refreshToken = data['refresh_token']?.toString();
    final userJson = data['user'];
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty ||
        userJson is! Map) {
      throw const UnknownException(message: 'Invalid login response');
    }
    final user = UserModel.fromApiJson(Map<String, dynamic>.from(userJson));
    return ParsedSocialAuthResponse(
      result: SocialLoginAuthenticated(user),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  static ParsedSocialCompletionResponse parseCompletion(
    Map<String, dynamic> body,
  ) {
    final data = body['data'];
    if (body['code'] != 'REGISTRATION_COMPLETED' || data is! Map) {
      throw const UnknownException(message: 'Response completion tidak valid');
    }
    final result = Map<String, dynamic>.from(data);
    final accessToken = result['access_token']?.toString();
    final refreshToken = result['refresh_token']?.toString();
    final userJson = result['user'];
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty ||
        userJson is! Map) {
      throw const UnknownException(message: 'Response completion tidak valid');
    }
    return ParsedSocialCompletionResponse(
      user: UserModel.fromApiJson(Map<String, dynamic>.from(userJson)),
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }
}
