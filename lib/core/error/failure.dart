// lib/core/error/failure.dart
import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String? message;
  final int? statusCode;

  const Failure({this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message, super.statusCode});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message, super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure({super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message, super.statusCode});
}
