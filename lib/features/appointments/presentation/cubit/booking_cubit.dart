import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/clock.dart';
import '../../../doctors/domain/doctor.dart';
import '../../../doctors/domain/doctor_repository.dart';
import '../../domain/appointment.dart';
import '../../domain/appointment_repository.dart';

enum BookingStatus { loading, ready, submitting, success, failure }

final class BookingState extends Equatable {
  const BookingState({
    this.status = BookingStatus.loading,
    this.doctor,
    this.days = const [],
    this.selectedDay,
    this.slots = const [],
    this.selectedSlot,
    this.type = ConsultationType.video,
    this.booked,
    this.error,
  });

  final BookingStatus status;
  final Doctor? doctor;
  final List<DateTime> days;
  final DateTime? selectedDay;
  final List<DateTime> slots;
  final DateTime? selectedSlot;
  final ConsultationType type;
  final Appointment? booked;
  final String? error;

  bool get canConfirm => doctor != null && selectedSlot != null && status == BookingStatus.ready;

  BookingState copyWith({
    BookingStatus? status,
    Doctor? doctor,
    List<DateTime>? days,
    DateTime? selectedDay,
    List<DateTime>? slots,
    DateTime? Function()? selectedSlot,
    ConsultationType? type,
    Appointment? booked,
    String? Function()? error,
  }) =>
      BookingState(
        status: status ?? this.status,
        doctor: doctor ?? this.doctor,
        days: days ?? this.days,
        selectedDay: selectedDay ?? this.selectedDay,
        slots: slots ?? this.slots,
        selectedSlot: selectedSlot != null ? selectedSlot() : this.selectedSlot,
        type: type ?? this.type,
        booked: booked ?? this.booked,
        error: error != null ? error() : this.error,
      );

  @override
  List<Object?> get props => [status, doctor, days, selectedDay, slots, selectedSlot, type, booked, error];
}

class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required DoctorRepository doctors,
    required AppointmentRepository appointments,
    Clock clock = const Clock(),
  })  : _doctors = doctors,
        _appointments = appointments,
        _clock = clock,
        super(const BookingState());

  final DoctorRepository _doctors;
  final AppointmentRepository _appointments;
  final Clock _clock;

  static const bookableDays = 7;

  Future<void> load(String doctorId) async {
    final doctor = await _doctors.getDoctor(doctorId);
    if (doctor == null) {
      emit(state.copyWith(status: BookingStatus.failure, error: () => 'Doctor not found'));
      return;
    }
    final now = _clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(bookableDays, (i) => today.add(Duration(days: i)));
    emit(state.copyWith(doctor: doctor, days: days));
    await selectDay(days.first);
  }

  Future<void> selectDay(DateTime day) async {
    final doctor = state.doctor;
    if (doctor == null) return;
    emit(state.copyWith(status: BookingStatus.loading, selectedDay: day, selectedSlot: () => null));
    final all = await _doctors.getSlots(doctor.id, day);
    final now = _clock.now();
    final taken = _appointments.current
        .where((a) => a.doctor.id == doctor.id && a.status == AppointmentStatus.upcoming)
        .map((a) => a.start)
        .toSet();
    final free = all.where((s) => s.isAfter(now) && !taken.contains(s)).toList();
    emit(state.copyWith(status: BookingStatus.ready, slots: free, error: () => null));
  }

  void selectSlot(DateTime slot) {
    if (!state.slots.contains(slot)) return;
    emit(state.copyWith(selectedSlot: () => slot, error: () => null));
  }

  void selectType(ConsultationType type) => emit(state.copyWith(type: type));

  Future<void> confirm() async {
    if (!state.canConfirm) return;
    emit(state.copyWith(status: BookingStatus.submitting));
    try {
      final appointment = await _appointments.book(
        doctor: state.doctor!,
        start: state.selectedSlot!,
        type: state.type,
      );
      emit(state.copyWith(status: BookingStatus.success, booked: appointment));
    } on SlotUnavailableException catch (e) {
      emit(state.copyWith(
        status: BookingStatus.ready,
        slots: state.slots.where((s) => s != state.selectedSlot).toList(),
        selectedSlot: () => null,
        error: () => e.toString(),
      ));
    }
  }
}
