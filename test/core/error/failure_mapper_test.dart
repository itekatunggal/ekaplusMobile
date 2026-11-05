import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/core/error/failure_mapper.dart';
import 'package:ekaplus_ekatunggal/core/network/network_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapExceptionToFailure', () {
    test('maps NetworkException to NetworkFailure', () {
      final failure = mapExceptionToFailure(
        const NetworkException(message: 'offline'),
      );

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'offline');
    });

    test('maps TimeoutException to TimeoutFailure', () {
      final failure = mapExceptionToFailure(
        const TimeoutException(message: 'timeout'),
      );

      expect(failure, isA<TimeoutFailure>());
      expect(failure.message, 'timeout');
    });

    test('maps ServerException to ServerFailure with status code', () {
      final failure = mapExceptionToFailure(
        const ServerException(message: 'broken', statusCode: 503),
      );

      expect(failure, isA<ServerFailure>());
      expect(failure.statusCode, 503);
      expect(failure.message, 'broken');
    });
  });
}
