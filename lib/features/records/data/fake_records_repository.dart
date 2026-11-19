import '../domain/health_summary.dart';

class FakeRecordsRepository implements RecordsRepository {
  @override
  Future<HealthSummary> getSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return const HealthSummary(
      vitals: [
        Vital(
          kind: VitalKind.heartRate,
          title: 'Heart rate',
          value: '72',
          unit: 'bpm',
          status: 'Normal',
          history: [78, 74, 80, 71, 76, 70, 72],
        ),
        Vital(
          kind: VitalKind.bloodPressure,
          title: 'Blood pressure',
          value: '118/76',
          unit: 'mmHg',
          status: 'Normal',
          history: [124, 121, 126, 119, 122, 117, 118],
        ),
        Vital(
          kind: VitalKind.bloodSugar,
          title: 'Blood sugar',
          value: '96',
          unit: 'mg/dL',
          status: 'Fasting',
          history: [102, 98, 105, 99, 94, 97, 96],
        ),
        Vital(
          kind: VitalKind.sleep,
          title: 'Sleep',
          value: '7h 20m',
          unit: '',
          status: 'Good',
          history: [6.2, 7.1, 6.8, 7.5, 6.9, 8.0, 7.3],
        ),
      ],
      weeklySteps: [6400, 8200, 7100, 9800, 5400, 11200, 8600],
      prescriptions: [
        Prescription(name: 'Amlodipine', dosage: '5 mg · once daily', prescribedBy: 'Dr. Sarah Ahmed', daysLeft: 18),
        Prescription(name: 'Vitamin D3', dosage: '1000 IU · after breakfast', prescribedBy: 'Dr. Fatima Noor', daysLeft: 42),
      ],
    );
  }
}
