// lib/cubit/connection_status_state.dart

part of 'connection_status_cubit.dart';

enum ConnectionStatus { online, offline, serverIssue, low }

class ConnectionStateCubit {
  final ConnectionStatus status;

  const ConnectionStateCubit({required this.status});
}
