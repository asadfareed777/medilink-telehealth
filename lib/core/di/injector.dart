import 'package:get_it/get_it.dart';

import '../../features/appointments/data/in_memory_appointment_repository.dart';
import '../../features/appointments/domain/appointment_repository.dart';
import '../../features/doctors/data/fake_doctor_repository.dart';
import '../../features/doctors/domain/doctor_repository.dart';
import '../../features/records/data/fake_records_repository.dart';
import '../../features/records/domain/health_summary.dart';
import '../clock.dart';

final sl = GetIt.instance;

void configureDependencies() {
  sl
    ..registerLazySingleton<Clock>(() => const Clock())
    ..registerLazySingleton<DoctorRepository>(FakeDoctorRepository.new)
    ..registerLazySingleton<AppointmentRepository>(() => InMemoryAppointmentRepository(clock: sl()))
    ..registerLazySingleton<RecordsRepository>(FakeRecordsRepository.new);
}
