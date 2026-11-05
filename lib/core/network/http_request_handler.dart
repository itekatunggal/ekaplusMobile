import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import 'package:ekaplus_ekatunggal/core/network/network_exceptions.dart';
import 'package:http/http.dart' as http;

class HttpRequestHandler {
  const HttpRequestHandler._();

  static const Duration defaultTimeout = Duration(seconds: 15);

  static Future<T> guard<T>(
    Future<T> Function() action, {
    String? timeoutMessage,
    String? networkMessage,
    String? sslMessage,
    String? unknownMessage,
    Duration timeout = defaultTimeout,
  }) async {
    try {
      return await action().timeout(timeout);
    } on async.TimeoutException {
      throw TimeoutException(
        message: timeoutMessage ?? 'Permintaan ke server melebihi batas waktu',
      );
    } on HandshakeException catch (error) {
      throw SslException(
        message: sslMessage ?? 'Terjadi masalah keamanan koneksi',
        body: error.toString(),
      );
    } on SocketException catch (error) {
      throw NetworkException(
        message: networkMessage ?? 'Koneksi internet tidak tersedia',
        body: error.toString(),
      );
    } on http.ClientException catch (error) {
      throw NetworkException(
        message: networkMessage ?? error.message,
        body: error.toString(),
      );
    } on AppNetworkException {
      rethrow;
    } catch (error) {
      throw UnknownException(
        message: unknownMessage ?? 'Terjadi kesalahan yang tidak diketahui',
        body: error.toString(),
      );
    }
  }

  static Future<http.Response> send(
    Future<http.Response> Function() request, {
    Future<http.Response> Function()? retryOnUnauthorized,
    Duration timeout = defaultTimeout,
    String? timeoutMessage,
    String? networkMessage,
    String? sslMessage,
    String? unknownMessage,
    String? defaultServerMessage,
    Set<int> successCodes = const {200},
  }) async {
    final response = await guard(
      request,
      timeout: timeout,
      timeoutMessage: timeoutMessage,
      networkMessage: networkMessage,
      sslMessage: sslMessage,
      unknownMessage: unknownMessage,
    );

    if (response.statusCode == 401 && retryOnUnauthorized != null) {
      final retryResponse = await guard(
        retryOnUnauthorized,
        timeout: timeout,
        timeoutMessage: timeoutMessage,
        networkMessage: networkMessage,
        sslMessage: sslMessage,
        unknownMessage: unknownMessage,
      );
      return validateResponse(
        retryResponse,
        defaultServerMessage: defaultServerMessage,
        successCodes: successCodes,
      );
    }

    return validateResponse(
      response,
      defaultServerMessage: defaultServerMessage,
      successCodes: successCodes,
    );
  }

  static http.Response validateResponse(
    http.Response response, {
    String? defaultServerMessage,
    Set<int> successCodes = const {200},
  }) {
    if (successCodes.contains(response.statusCode)) {
      return response;
    }

    final message =
        extractMessage(response.body) ??
        defaultServerMessage ??
        'Permintaan ke server gagal';

    if (response.statusCode == 401) {
      throw UnauthorizedException(message: message, body: response.body);
    }

    throw ServerException(
      message: message,
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  static String? extractMessage(String? responseBody) {
    if (responseBody == null || responseBody.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message != null && message.toString().trim().isNotEmpty) {
          return message.toString();
        }
        final errors = decoded['errors'];
        if (errors != null && errors.toString().trim().isNotEmpty) {
          return errors.toString();
        }
      }
    } catch (_) {
      // Fall back to raw body.
    }

    return responseBody.trim().isEmpty ? null : responseBody;
  }
}
