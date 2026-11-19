import 'package:equatable/equatable.dart';

import '../../doctors/domain/doctor.dart';

enum ConsultationType {
  video('Video call'),
  clinic('In clinic');

  const ConsultationType(this.label);
  final String label;
}

enum AppointmentStatus { upcoming, completed, cancelled }

class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.doctor,
    required this.start,
    required this.type,
    this.status = AppointmentStatus.upcoming,
  });

  final String id;
  final Doctor doctor;
  final DateTime start;
  final ConsultationType type;
  final AppointmentStatus status;

  static const duration = Duration(minutes: 30);

  Appointment copyWith({AppointmentStatus? status}) =>
      Appointment(id: id, doctor: doctor, start: start, type: type, status: status ?? this.status);

  @override
  List<Object?> get props => [id, doctor, start, type, status];
}
