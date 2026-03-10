import 'dart:io';

import 'package:ekaplus_ekatunggal/core/network/http_request_handler.dart';
import 'package:ekaplus_ekatunggal/core/network/network_exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('HttpRequestHandler.send', () {
    test('maps socket failures to NetworkException', () async {
      expect(
        () => HttpRequestHandler.send(
          () async => throw const SocketException('offline'),
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('maps request timeouts to TimeoutException', () async {
      expect(
        () => HttpRequestHandler.send(() async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return http.Response('ok', 200);
        }, timeout: const Duration(milliseconds: 1)),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('maps 401 to UnauthorizedException', () async {
      expect(
        () => HttpRequestHandler.send(
          () async => http.Response('{"message":"expired"}', 401),
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('maps server responses to ServerException with status code', () async {
      try {
        await HttpRequestHandler.send(
          () async => http.Response('{"message":"server down"}', 500),
        );
        fail('Expected ServerException');
      } on ServerException catch (error) {
        expect(error.statusCode, 500);
        expect(error.message, 'server down');
      }
    });
  });
}
