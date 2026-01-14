// lib/features/auth/presentation/bloc/otp_timer/otp_timer_bloc.dart
import 'dart:async';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_event.dart';
import 'package:ekaplus_ekatunggal/features/auth/presentation/bloc/otp_timer/otp_timer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpTimerBloc extends Bloc<OtpTimerEvent, OtpTimerState> {
  Timer? _timer;

  OtpTimerBloc() : super(OtpTimerInitial()) {
    on<StartOtpTimer>(_onStartTimer);
    on<OtpTimerTicked>(_onTimerTicked);
    on<ResetOtpTimer>(_onResetTimer);
  }

  void _onStartTimer(StartOtpTimer event, Emitter<OtpTimerState> emit) {
    // Cancel timer sebelumnya jika ada
    _timer?.cancel();

    emit(OtpTimerRunning(event.duration));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = event.duration - timer.tick;

      if (remaining > 0) {
        add(OtpTimerTicked(remaining));
      } else {
        timer.cancel();
        add(const OtpTimerTicked(0));
      }
    });
  }

  void _onTimerTicked(OtpTimerTicked event, Emitter<OtpTimerState> emit) {
    if (event.remainingSeconds > 0) {
      emit(OtpTimerRunning(event.remainingSeconds));
    } else {
      emit(OtpTimerCompleted());
    }
  }

  void _onResetTimer(ResetOtpTimer event, Emitter<OtpTimerState> emit) {
    _timer?.cancel();

    emit(OtpTimerInitial());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
