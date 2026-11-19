import 'package:equatable/equatable.dart';

enum VitalKind { heartRate, bloodPressure, bloodSugar, sleep }

class Vital extends Equatable {
  const Vital({
    required this.kind,
    required this.title,
    required this.value,
    required this.unit,
    required this.status,
    required this.history,
  });

  final VitalKind kind;
  final String title;
  final String value;
  final String unit;
  final String status;

  /// Last 7 readings, oldest first: drives the sparkline.
  final List<double> history;

  @override
  List<Object?> get props => [kind, value, history];
}

class Prescription extends Equatable {
  const Prescription({required this.name, required this.dosage, required this.prescribedBy, required this.daysLeft});

  final String name;
  final String dosage;
  final String prescribedBy;
  final int daysLeft;

  @override
  List<Object?> get props => [name, dosage];
}

class HealthSummary extends Equatable {
  const HealthSummary({required this.vitals, required this.weeklySteps, required this.prescriptions});

  final List<Vital> vitals;
  final List<int> weeklySteps;
  final List<Prescription> prescriptions;

  int get stepsAverage => weeklySteps.isEmpty ? 0 : weeklySteps.reduce((a, b) => a + b) ~/ weeklySteps.length;

  @override
  List<Object?> get props => [vitals, weeklySteps, prescriptions];
}

abstract interface class RecordsRepository {
  Future<HealthSummary> getSummary();
}
