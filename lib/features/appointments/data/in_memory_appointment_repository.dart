import 'dart:async';

import '../../../core/clock.dart';
import '../../doctors/data/fake_doctor_repository.dart';
import '../../doctors/domain/doctor.dart';
import '../domain/appointment.dart';
import '../domain/appointment_repository.dart';

class InMemoryAppointmentRepository implements AppointmentRepository {
  InMemoryAppointmentRepository({
    Clock clock = const Clock(),
    bool seed = true,
    this.latency = const Duration(milliseconds: 400),
  }) : _clock = clock {
    if (seed) _seed();
  }

  final Clock _clock;
  final Duration latency;
  final _controller = StreamController<List<Appointment>>.broadcast();
  final List<Appointment> _items = [];
  int _nextId = 100;

  void _seed() {
    final now = _clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final docs = FakeDoctorRepository.doctors;
    _items.addAll([
      Appointment(
        id: 'a1',
        doctor: docs[0],
        start: today.add(const Duration(days: 1, hours: 10, minutes: 30)),
        type: ConsultationType.video,
      ),
      Appointment(
        id: 'a2',
        doctor: docs[2],
        start: today.add(const Duration(days: 4, hours: 15)),
        type: ConsultationType.clinic,
      ),
      Appointment(
        id: 'a3',
        doctor: docs[4],
        start: today.subtract(const Duration(days: 6)).add(const Duration(hours: 11)),
        type: ConsultationType.video,
        status: AppointmentStatus.completed,
      ),
      Appointment(
        id: 'a4',
        doctor: docs[1],
        start: today.subtract(const Duration(days: 20)).add(const Duration(hours: 14, minutes: 30)),
        type: ConsultationType.clinic,
        status: AppointmentStatus.completed,
      ),
    ]);
  }

  @override
  List<Appointment> get current => List.unmodifiable(_items);

  @override
  Stream<List<Appointment>> watchAppointments() async* {
    yield current;
    yield* _controller.stream;
  }

  @override
  Appointment? byId(String id) {
    for (final a in _items) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<Appointment> book({
    required Doctor doctor,
    required DateTime start,
    required ConsultationType type,
  }) async {
    await Future<void>.delayed(latency);
    final clash = _items.any((a) =>
        a.doctor.id == doctor.id && a.start == start && a.status == AppointmentStatus.upcoming);
    if (clash) throw const SlotUnavailableException();

    final appointment = Appointment(id: 'a${_nextId++}', doctor: doctor, start: start, type: type);
    _items.add(appointment);
    _emit();
    return appointment;
  }

  @override
  Future<void> cancel(String appointmentId) async {
    await Future<void>.delayed(latency);
    final i = _items.indexWhere((a) => a.id == appointmentId);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(status: AppointmentStatus.cancelled);
    _emit();
  }

  void _emit() => _controller.add(current);

  Future<void> dispose() => _controller.close();
}
