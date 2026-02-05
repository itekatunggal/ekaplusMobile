// lib/cubit/connection_status_cubit.dart
import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:ekaplus_ekatunggal/core/config/api_config.dart';
import 'package:http/http.dart' as http;
part 'connection_status_state.dart';

class ConnectionCubit extends Cubit<ConnectionStateCubit> {
  int errorCount = 0;
  ConnectionStatus _lastStatus = ConnectionStatus.online;
  ConnectionCubit()
    : super(const ConnectionStateCubit(status: ConnectionStatus.online));

  // Fungsi untuk memulai pemantauan status koneksi
  Future<void> startMonitoringConnection() async {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      final status = await _checkConnectionStatus();
      _emitStatus(status);
    });
  }

  // Fungsi untuk memeriksa koneksi internet dengan melakukan request ke API

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('cloudflare.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<ConnectionStatus> _checkConnectionStatus() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.baseUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 408 || response.statusCode >= 500) {
        return ConnectionStatus.serverIssue;
      }

      // Any non-5xx response means the server is reachable.
      // This covers 404/401/403 that many APIs return on base URL.
      return ConnectionStatus.online;
    } on TimeoutException {
      return ConnectionStatus.serverIssue;
    } on HandshakeException {
      return ConnectionStatus.serverIssue;
    } on SocketException {
      final hasInternet = await _hasInternet();
      return hasInternet
          ? ConnectionStatus.serverIssue
          : ConnectionStatus.offline;
    } catch (_) {
      return ConnectionStatus.serverIssue;
    }
  }

  void _emitStatus(ConnectionStatus status, {bool useThreshold = true}) {
    if (status == ConnectionStatus.online) {
      errorCount = 0;
      _lastStatus = status;
      emit(const ConnectionStateCubit(status: ConnectionStatus.online));
      return;
    }

    if (!useThreshold) {
      errorCount = 0;
      _lastStatus = status;
      emit(ConnectionStateCubit(status: status));
      return;
    }

    if (_lastStatus != status) {
      _lastStatus = status;
      errorCount = 1;
    } else {
      errorCount = errorCount + 1;
    }

    if (errorCount > 1) {
      emit(ConnectionStateCubit(status: status));
    }
  }

  // Fungsi untuk manual check koneksi (triggered dari dialog button)
  Future<void> checkConnection() async {
    final status = await _checkConnectionStatus();
    _emitStatus(status, useThreshold: false);
  }
}
