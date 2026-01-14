// lib/features/auth/presentation/bloc/otp_timer/otp_timer_state.dart
import 'package:equatable/equatable.dart';

abstract class OtpTimerState extends Equatable {
  const OtpTimerState();

  @override
  List<Object> get props => [];
}

class OtpTimerInitial extends OtpTimerState {}

class OtpTimerRunning extends OtpTimerState {
  final int remainingSeconds;

  const OtpTimerRunning(this.remainingSeconds);

  @override
  List<Object> get props => [remainingSeconds];

  // Helper untuk format MM:SS
  String get formattedTime {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class OtpTimerCompleted extends OtpTimerState {}