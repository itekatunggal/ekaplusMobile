abstract class AppNetworkException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  const AppNetworkException({
    required this.message,
    this.statusCode,
    this.body,
  });

  @override
  String toString() => message;
}

class NetworkException extends AppNetworkException {
  const NetworkException({
    super.message = 'Koneksi internet tidak tersedia',
    super.body,
  });
}

class TimeoutException extends AppNetworkException {
  const TimeoutException({
    super.message = 'Permintaan ke server melebihi batas waktu',
    super.body,
  });
}

class ServerException extends AppNetworkException {
  const ServerException({
    super.message = 'Terjadi kesalahan pada server',
    super.statusCode,
    super.body,
  });
}

class UnauthorizedException extends AppNetworkException {
  const UnauthorizedException({
    super.message = 'Sesi login berakhir',
    super.statusCode = 401,
    super.body,
  });
}

class SslException extends AppNetworkException {
  const SslException({
    super.message = 'Terjadi masalah keamanan koneksi',
    super.body,
  });
}

class UnknownException extends AppNetworkException {
  const UnknownException({
    super.message = 'Terjadi kesalahan yang tidak diketahui',
    super.statusCode,
    super.body,
  });
}
