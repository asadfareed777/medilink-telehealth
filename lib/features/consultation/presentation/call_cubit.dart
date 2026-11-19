import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum CallPhase { connecting, live, ended }

final class CallState extends Equatable {
  const CallState({
    this.phase = CallPhase.connecting,
    this.elapsed = Duration.zero,
    this.micOn = true,
    this.cameraOn = true,
    this.frontCamera = true,
  });

  final CallPhase phase;
  final Duration elapsed;
  final bool micOn;
  final bool cameraOn;
  final bool frontCamera;

  String get timer {
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  CallState copyWith({CallPhase? phase, Duration? elapsed, bool? micOn, bool? cameraOn, bool? frontCamera}) =>
      CallState(
        phase: phase ?? this.phase,
        elapsed: elapsed ?? this.elapsed,
        micOn: micOn ?? this.micOn,
        cameraOn: cameraOn ?? this.cameraOn,
        frontCamera: frontCamera ?? this.frontCamera,
      );

  @override
  List<Object?> get props => [phase, elapsed, micOn, cameraOn, frontCamera];
}

/// Call-session state. In production this would wrap a WebRTC SDK
/// (e.g. Agora / Twilio / flutter_webrtc); the UI only depends on [CallState].
class CallCubit extends Cubit<CallState> {
  CallCubit({this.connectDelay = const Duration(seconds: 2), this.tick = const Duration(seconds: 1)})
      : super(const CallState());

  final Duration connectDelay;
  final Duration tick;
  Timer? _connectTimer;
  Timer? _ticker;

  void start() {
    _connectTimer = Timer(connectDelay, () {
      if (isClosed) return;
      emit(state.copyWith(phase: CallPhase.live));
      _ticker = Timer.periodic(tick, (_) {
        if (!isClosed) emit(state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1)));
      });
    });
  }

  void toggleMic() => emit(state.copyWith(micOn: !state.micOn));

  void toggleCamera() => emit(state.copyWith(cameraOn: !state.cameraOn));

  void flipCamera() => emit(state.copyWith(frontCamera: !state.frontCamera));

  void hangUp() {
    _connectTimer?.cancel();
    _ticker?.cancel();
    emit(state.copyWith(phase: CallPhase.ended));
  }

  @override
  Future<void> close() {
    _connectTimer?.cancel();
    _ticker?.cancel();
    return super.close();
  }
}
