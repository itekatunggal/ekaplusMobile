import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'social_auth_exception.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  StreamSubscription? _sub;

  Future<void> init({serverClientId}) async {
    await _googleSignIn.initialize(serverClientId: serverClientId);
  }

  Future<String> loginAndGetIdToken() async {
    final completer = Completer<String>();

    _sub = _googleSignIn.authenticationEvents.listen((event) async {
      if (completer.isCompleted) return;

      if (event is GoogleSignInAuthenticationEventSignIn) {
        final auth = event.user.authentication;
        final idToken = auth.idToken;

        if (idToken == null || idToken.isEmpty) {
          completer.completeError(Exception('ID token kosong'));
        } else {
          completer.complete(idToken);
        }

        await _sub?.cancel();
      }

      if (event is GoogleSignInAuthenticationEventSignOut) {
        completer.completeError(const SocialSignInCancelledException());
        await _sub?.cancel();
      }
    });

    // 🔥 INI SATU-SATUNYA CARA LOGIN DI SDK BARU
    try {
      await _googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      await _sub?.cancel();
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialSignInCancelledException();
      }
      rethrow;
    }

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () async {
        await _sub?.cancel();
        throw Exception('Google login timeout');
      },
    );
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _googleSignIn.disconnect();
  }
}
