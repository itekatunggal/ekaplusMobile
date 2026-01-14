// ignore_for_file: library_prefixes

import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/core/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

part 'socket_state.dart';

class SocketCubit extends Cubit<SocketState> {
  late IO.Socket socket;

  SocketCubit() : super(SocketInitial()) {
    _initializeSocket();
  }

  void _initializeSocket() {
    try {
      socket = IO.io(
        Constants.apiBaseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .setReconnectionAttempts(5)
            .enableAutoConnect()
            .build(),
      );

      socket.onConnect((_) {
        emit(SocketConnected());
      });

      socket.onDisconnect((_) {
        emit(SocketDisconnected());
      });

      socket.on('biding', (data) {
        if (data) {
          emit(SocketToBidding());
        } else {
          emit(SocketConnected());
        }
      });

      socket.onAny((event, data) {
        emit(SocketInitial());
        emit(SocketMessageReceived(data));
      });
    } catch (e) {
      emit(SocketError('Error initializing socket: $e'));
    }
  }

  void sendMessage(String event, dynamic data) {
    socket.emit(event, data);
  }

  void disconnect() {
    socket.disconnect();
    emit(SocketDisconnected());
  }
}
