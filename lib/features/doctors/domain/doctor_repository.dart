import 'doctor.dart';

abstract interface class DoctorRepository {
  Future<List<Doctor>> getDoctors();

  Future<Doctor?> getDoctor(String id);

  /// Start times of the doctor's consultation slots on [day] (date part only).
  Future<List<DateTime>> getSlots(String doctorId, DateTime day);
}
