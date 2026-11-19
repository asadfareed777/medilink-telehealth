import '../../doctors/domain/doctor.dart';
import 'appointment.dart';

class SlotUnavailableException implements Exception {
  const SlotUnavailableException();
  @override
  String toString() => 'This time slot was just booked. Please pick another.';
}

abstract interface class AppointmentRepository {
  /// Emits the full list immediately and after every change.
  Stream<List<Appointment>> watchAppointments();

  List<Appointment> get current;

  Appointment? byId(String id);

  /// Throws [SlotUnavailableException] if the doctor already has a booking at [start].
  Future<Appointment> book({
    required Doctor doctor,
    required DateTime start,
    required ConsultationType type,
  });

  Future<void> cancel(String appointmentId);
}
