// lib/features/auth/presentation/bloc/otp_timer/otp_timer_event.dart
import 'package:equatable/equatable.dart';

abstract class OtpTimerEvent extends Equatable {
  const OtpTimerEvent();

  @override
  List<Object> get props => [];
}

class StartOtpTimer extends OtpTimerEvent {
  final int duration; // dalam detik

  const StartOtpTimer({this.duration = 60}); // default 60 detik

  @override
  List<Object> get props => [duration];
}

class OtpTimerTicked extends OtpTimerEvent {
  final int remainingSeconds;

  const OtpTimerTicked(this.remainingSeconds);

  @override
  List<Object> get props => [remainingSeconds];
}

class ResetOtpTimer extends OtpTimerEvent {}