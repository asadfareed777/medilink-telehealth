import 'package:flutter_test/flutter_test.dart';
import 'package:medilink/core/clock.dart';
import 'package:medilink/features/appointments/data/in_memory_appointment_repository.dart';
import 'package:medilink/features/appointments/domain/appointment.dart';
import 'package:medilink/features/appointments/presentation/cubit/booking_cubit.dart';
import 'package:medilink/features/doctors/data/fake_doctor_repository.dart';

void main() {
  // Monday 10 Nov 2025, 08:00
  final now = DateTime(2025, 11, 10, 8);
  final clock = FixedClock(now);

  late FakeDoctorRepository doctors;
  late InMemoryAppointmentRepository appointments;
  late BookingCubit cubit;

  setUp(() {
    doctors = FakeDoctorRepository(latency: Duration.zero);
    appointments = InMemoryAppointmentRepository(clock: clock, seed: false, latency: Duration.zero);
    cubit = BookingCubit(doctors: doctors, appointments: appointments, clock: clock);
  });

  tearDown(() async {
    await cubit.close();
    await appointments.dispose();
  });

  test('load builds a 7-day window starting today and selects today', () async {
    await cubit.load('d1');

    expect(cubit.state.doctor?.id, 'd1');
    expect(cubit.state.days, hasLength(BookingCubit.bookableDays));
    expect(cubit.state.days.first, DateTime(2025, 11, 10));
    expect(cubit.state.selectedDay, DateTime(2025, 11, 10));
    expect(cubit.state.status, BookingStatus.ready);
    expect(cubit.state.slots, isNotEmpty);
  });

  test('unknown doctor yields failure', () async {
    await cubit.load('nope');
    expect(cubit.state.status, BookingStatus.failure);
  });

  test('slots exclude the lunch break and past times', () async {
    final late = BookingCubit(
      doctors: doctors,
      appointments: appointments,
      clock: FixedClock(DateTime(2025, 11, 10, 14, 10)),
    );
    await late.load('d1');

    expect(late.state.slots.every((s) => s.isAfter(DateTime(2025, 11, 10, 14, 10))), isTrue);
    expect(late.state.slots.any((s) => s.hour == 12), isFalse);
    await late.close();
  });

  test('confirm books the selected slot and hides it on next load', () async {
    await cubit.load('d1');
    final slot = cubit.state.slots.first;
    cubit
      ..selectType(ConsultationType.clinic)
      ..selectSlot(slot);
    expect(cubit.state.canConfirm, isTrue);

    await cubit.confirm();

    expect(cubit.state.status, BookingStatus.success);
    expect(cubit.state.booked?.start, slot);
    expect(cubit.state.booked?.type, ConsultationType.clinic);
    expect(appointments.current, hasLength(1));

    final again = BookingCubit(doctors: doctors, appointments: appointments, clock: clock);
    await again.load('d1');
    expect(again.state.slots, isNot(contains(slot)));
    await again.close();
  });

  test('double booking surfaces an error and removes the slot', () async {
    await cubit.load('d1');
    final slot = cubit.state.slots.first;
    // Someone else books it first.
    await appointments.book(doctor: cubit.state.doctor!, start: slot, type: ConsultationType.video);

    cubit.selectSlot(slot);
    await cubit.confirm();

    expect(cubit.state.status, BookingStatus.ready);
    expect(cubit.state.error, isNotNull);
    expect(cubit.state.slots, isNot(contains(slot)));
    expect(cubit.state.selectedSlot, isNull);
  });

  test('cannot select a slot that is not offered', () async {
    await cubit.load('d1');
    cubit.selectSlot(DateTime(2030));
    expect(cubit.state.selectedSlot, isNull);
  });
}
