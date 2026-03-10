import 'package:ekaplus_ekatunggal/core/error/failure.dart';
import 'package:ekaplus_ekatunggal/core/network/network_exceptions.dart';

Failure mapExceptionToFailure(Object error, {String? fallbackMessage}) {
  if (error is Failure) {
    return error;
  }

  if (error is UnauthorizedException) {
    return UnauthorizedFailure(
      message: error.message,
      statusCode: error.statusCode,
    );
  }

  if (error is TimeoutException) {
    return TimeoutFailure(message: error.message);
  }

  if (error is NetworkException) {
    return NetworkFailure(message: error.message);
  }

  if (error is SslException) {
    return ServerFailure(message: error.message);
  }

  if (error is ServerException) {
    return ServerFailure(message: error.message, statusCode: error.statusCode);
  }

  if (error is UnknownException) {
    return UnknownFailure(message: error.message, statusCode: error.statusCode);
  }

  return UnknownFailure(message: fallbackMessage ?? error.toString());
}
