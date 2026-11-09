import 'package:ekaplus_ekatunggal/features/auth/data/models/social_auth_response_parser.dart';
import 'package:ekaplus_ekatunggal/features/auth/domain/entities/social_auth_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('REGISTRATION_REQUIRED tidak diperlakukan sebagai login sukses', () {
    final parsed = SocialAuthResponseParser.parseLogin({
      'status': 'success',
      'code': 'REGISTRATION_REQUIRED',
      'data': {
        'registration_required': true,
        'registration_token': 'ticket-rahasia',
        'expires_in': 600,
        'prefill': {'email': 'budi@example.com'},
      },
    }, provider: SocialProvider.google);

    expect(parsed.result, isA<SocialRegistrationPending>());
    expect(parsed.accessToken, isNull);
    expect(parsed.refreshToken, isNull);
    final pending = parsed.result as SocialRegistrationPending;
    expect(pending.prefill.email, 'budi@example.com');
    expect(pending.expiresIn, 600);
  });

  test('login lengkap membutuhkan user dan kedua token', () {
    final parsed = SocialAuthResponseParser.parseLogin({
      'status': 'success',
      'data': {
        'user': {'id': 123, 'username': 'budi'},
        'access_token': 'access',
        'refresh_token': 'refresh',
      },
    }, provider: SocialProvider.apple);

    expect(parsed.result, isA<SocialLoginAuthenticated>());
    expect(parsed.accessToken, 'access');
    expect(parsed.refreshToken, 'refresh');
  });

  test('completion sukses mem-parsing user dan token', () {
    final parsed = SocialAuthResponseParser.parseCompletion({
      'status': 'success',
      'code': 'REGISTRATION_COMPLETED',
      'data': {
        'user': {
          'id': 123,
          'username': 'budi_123',
          'email': 'budi@example.com',
        },
        'access_token': 'access',
        'refresh_token': 'refresh',
      },
    });

    expect(parsed.user.username, 'budi_123');
    expect(parsed.accessToken, 'access');
    expect(parsed.refreshToken, 'refresh');
  });
}
