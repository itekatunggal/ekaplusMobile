import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'social_auth_exception.dart';

class AppleAuthService {
  Future<String> loginAndGetIdentityToken() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.email],
      );
      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw StateError('Identity token Apple kosong');
      }
      return identityToken;
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const SocialSignInCancelledException();
      }
      rethrow;
    }
  }
}
