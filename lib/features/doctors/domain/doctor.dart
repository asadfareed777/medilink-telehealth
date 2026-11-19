import 'package:equatable/equatable.dart';

enum Specialty {
  general('General'),
  cardiology('Cardiology'),
  dermatology('Dermatology'),
  pediatrics('Pediatrics'),
  neurology('Neurology'),
  orthopedics('Orthopedics');

  const Specialty(this.label);
  final String label;
}

class Doctor extends Equatable {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.rating,
    required this.reviews,
    required this.yearsExperience,
    required this.patients,
    required this.fee,
    required this.about,
    this.availableToday = false,
  });

  final String id;
  final String name;
  final Specialty specialty;
  final String hospital;
  final double rating;
  final int reviews;
  final int yearsExperience;
  final int patients;

  /// Consultation fee in whole US dollars.
  final int fee;
  final String about;
  final bool availableToday;

  String get initials => name
      .replaceFirst('Dr. ', '')
      .split(' ')
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0])
      .join();

  @override
  List<Object?> get props => [id];
}
