import 'package:flutter_test/flutter_test.dart';
import 'package:medilink/core/clock.dart';
import 'package:medilink/features/appointments/data/in_memory_appointment_repository.dart';
import 'package:medilink/features/appointments/domain/appointment.dart';
import 'package:medilink/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:medilink/features/consultation/presentation/call_cubit.dart';

void main() {
  final clock = FixedClock(DateTime(2025, 11, 10, 9));

  group('AppointmentsCubit', () {
    late InMemoryAppointmentRepository repo;
    late AppointmentsCubit cubit;

    setUp(() {
      repo = InMemoryAppointmentRepository(clock: clock, latency: Duration.zero);
      cubit = AppointmentsCubit(repo, clock: clock)..start();
    });

    tearDown(() async {
      await cubit.close();
      await repo.dispose();
    });

    test('splits seeded data into upcoming (soonest first) and past (latest first)', () async {
      await pumpEventQueue();
      final s = cubit.state;

      expect(s.upcoming.map((a) => a.id), ['a1', 'a2']);
      expect(s.past.map((a) => a.id), ['a3', 'a4']);
      expect(s.next?.id, 'a1');
    });

    test('cancelling moves an appointment to past with cancelled status', () async {
      await pumpEventQueue();
      await cubit.cancel('a1');
      await pumpEventQueue();

      expect(cubit.state.upcoming.map((a) => a.id), ['a2']);
      final cancelled = cubit.state.past.firstWhere((a) => a.id == 'a1');
      expect(cancelled.status, AppointmentStatus.cancelled);
      expect(cubit.state.cancellingId, isNull);
    });
  });

  group('CallCubit', () {
    test('connects, ticks and hangs up', () async {
      final call = CallCubit(connectDelay: const Duration(milliseconds: 10), tick: const Duration(milliseconds: 10))
        ..start();
      expect(call.state.phase, CallPhase.connecting);

      await Future<void>.delayed(const Duration(milliseconds: 45));
      expect(call.state.phase, CallPhase.live);
      expect(call.state.elapsed.inSeconds, greaterThan(0));

      call
        ..toggleMic()
        ..toggleCamera();
      expect(call.state.micOn, isFalse);
      expect(call.state.cameraOn, isFalse);

      call.hangUp();
      expect(call.state.phase, CallPhase.ended);
      await call.close();
    });

    test('timer is formatted as mm:ss', () {
      expect(const CallState(elapsed: Duration(minutes: 3, seconds: 7)).timer, '03:07');
    });
  });
}
