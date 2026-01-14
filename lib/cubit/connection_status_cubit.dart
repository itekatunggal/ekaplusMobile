// lib/cubit/connection_status_cubit.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
part 'connection_status_state.dart';

class ConnectionCubit extends Cubit<ConnectionStateCubit> {
  int errorCount = 0;
  ConnectionCubit()
      : super(const ConnectionStateCubit(status: ConnectionStatus.online));

  // Fungsi untuk memulai pemantauan status koneksi
  Future<void> startMonitoringConnection() async {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      bool isOnline = await _checkInternetConnection();
      if (isOnline) {
        errorCount = 0;
        emit(const ConnectionStateCubit(status: ConnectionStatus.online));
      } else {
        errorCount = errorCount + 1;
        if (errorCount > 1) {
          emit(const ConnectionStateCubit(status: ConnectionStatus.offline));
        }
        //  else {
        //   emit(const ConnectionStateCubit(status: ConnectionStatus.low));
        // }
      }
    });
  }

  // Fungsi untuk memeriksa koneksi internet dengan melakukan request ke API
  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(
        Uri.parse('https://api-ekatalog.ekatunggal.com'),
      );
      return response.statusCode == 404;
    } catch (e) {
      return false;
    }
  }

  // Fungsi untuk manual check koneksi (triggered dari dialog button)
  Future<void> checkConnection() async {
    bool isOnline = await _checkInternetConnection();
    if (isOnline) {
      errorCount = 0;
      emit(const ConnectionStateCubit(status: ConnectionStatus.online));
    } else {
      emit(const ConnectionStateCubit(status: ConnectionStatus.offline));
    }
  }
}
