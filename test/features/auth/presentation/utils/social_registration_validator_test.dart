import 'package:ekaplus_ekatunggal/features/auth/presentation/utils/social_registration_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SocialRegistrationValidator.username', () {
    test('menerima format username yang didukung backend', () {
      expect(SocialRegistrationValidator.username('budi_123'), isNull);
      expect(SocialRegistrationValidator.username('Budi.Santoso'), isNull);
    });

    test('menolak spasi, karakter terlarang, dan panjang invalid', () {
      expect(SocialRegistrationValidator.username('ab'), isNotNull);
      expect(SocialRegistrationValidator.username('budi santoso'), isNotNull);
      expect(SocialRegistrationValidator.username('budi@test'), isNotNull);
      expect(SocialRegistrationValidator.username('a' * 31), isNotNull);
    });

    test('menolak reserved username tanpa membedakan kapital', () {
      expect(SocialRegistrationValidator.username('Admin'), isNotNull);
      expect(SocialRegistrationValidator.username('EKAPLUS'), isNotNull);
    });
  });

  group('SocialRegistrationValidator.password', () {
    test('menerima password 6 karakter tanpa aturan tambahan', () {
      expect(SocialRegistrationValidator.password('abcdef'), isNull);
    });

    test('menghitung batas sebagai byte UTF-8, bukan karakter', () {
      expect(SocialRegistrationValidator.password('é' * 36), isNull);
      expect(SocialRegistrationValidator.password('é' * 37), isNotNull);
    });

    test('tidak melakukan trim password', () {
      expect(SocialRegistrationValidator.password('      '), isNull);
    });
  });

  test('konfirmasi password harus sama persis', () {
    expect(
      SocialRegistrationValidator.confirmation('rahasia', 'rahasia'),
      isNull,
    );
    expect(
      SocialRegistrationValidator.confirmation('rahasia ', 'rahasia'),
      isNotNull,
    );
  });
}
