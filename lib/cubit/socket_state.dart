part of 'socket_cubit.dart';

abstract class SocketState {}

class SocketInitial extends SocketState {}

class SocketConnected extends SocketState {}

class SocketDisconnected extends SocketState {}

class SocketMessageReceived extends SocketState {
  final dynamic message;
  SocketMessageReceived(this.message);
}

class SocketToBidding extends SocketState {}

class SocketError extends SocketState {
  final String error;
  SocketError(this.error);
}
