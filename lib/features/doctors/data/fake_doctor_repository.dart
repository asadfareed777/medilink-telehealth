import '../domain/doctor.dart';
import '../domain/doctor_repository.dart';

/// Demo data source. Swap for a REST/GraphQL implementation in production.
class FakeDoctorRepository implements DoctorRepository {
  FakeDoctorRepository({this.latency = const Duration(milliseconds: 350)});

  final Duration latency;

  static const doctors = <Doctor>[
    Doctor(
      id: 'd1',
      name: 'Dr. Sarah Ahmed',
      specialty: Specialty.cardiology,
      hospital: 'Shifa International Hospital',
      rating: 4.9,
      reviews: 312,
      yearsExperience: 12,
      patients: 2400,
      fee: 40,
      availableToday: true,
      about: 'Consultant cardiologist focused on preventive cardiology, hypertension '
          'and heart-failure management. Fellow of the European Society of Cardiology.',
    ),
    Doctor(
      id: 'd2',
      name: 'Dr. Michael Chen',
      specialty: Specialty.dermatology,
      hospital: 'City Skin Clinic',
      rating: 4.8,
      reviews: 198,
      yearsExperience: 9,
      patients: 1800,
      fee: 35,
      availableToday: true,
      about: 'Board-certified dermatologist treating acne, eczema and pigmentation, '
          'with a special interest in teledermatology.',
    ),
    Doctor(
      id: 'd3',
      name: 'Dr. Ayesha Malik',
      specialty: Specialty.pediatrics,
      hospital: 'Children’s Health Centre',
      rating: 4.9,
      reviews: 421,
      yearsExperience: 15,
      patients: 3900,
      fee: 30,
      about: 'Pediatrician caring for newborns to adolescents: growth, nutrition, '
          'vaccinations and childhood infections.',
    ),
    Doctor(
      id: 'd4',
      name: 'Dr. James Wilson',
      specialty: Specialty.neurology,
      hospital: 'NeuroCare Institute',
      rating: 4.7,
      reviews: 156,
      yearsExperience: 18,
      patients: 2100,
      fee: 55,
      about: 'Neurologist specialising in migraine, epilepsy and sleep disorders.',
    ),
    Doctor(
      id: 'd5',
      name: 'Dr. Fatima Noor',
      specialty: Specialty.general,
      hospital: 'MediLink Virtual Clinic',
      rating: 4.8,
      reviews: 540,
      yearsExperience: 8,
      patients: 5200,
      fee: 20,
      availableToday: true,
      about: 'Family physician for everyday health concerns, chronic-condition '
          'follow-ups and prescriptions.',
    ),
    Doctor(
      id: 'd6',
      name: 'Dr. Omar Farooq',
      specialty: Specialty.orthopedics,
      hospital: 'Bone & Joint Hospital',
      rating: 4.6,
      reviews: 134,
      yearsExperience: 11,
      patients: 1600,
      fee: 45,
      about: 'Orthopaedic surgeon treating sports injuries, back pain and arthritis.',
    ),
  ];

  @override
  Future<List<Doctor>> getDoctors() async {
    await Future<void>.delayed(latency);
    return doctors;
  }

  @override
  Future<Doctor?> getDoctor(String id) async {
    await Future<void>.delayed(latency);
    for (final d in doctors) {
      if (d.id == id) return d;
    }
    return null;
  }

  @override
  Future<List<DateTime>> getSlots(String doctorId, DateTime day) async {
    await Future<void>.delayed(latency);
    // Deterministic pseudo-availability: 09:00–17:00 every 30 min,
    // with a few slots removed depending on the doctor and the weekday.
    final seed = doctorId.codeUnits.fold<int>(0, (a, b) => a + b) + day.weekday;
    final slots = <DateTime>[];
    for (var i = 0; i < 16; i++) {
      if ((i + seed) % 4 == 0) continue;
      if (i == 6 || i == 7) continue; // lunch break 12:00–13:00
      slots.add(DateTime(day.year, day.month, day.day, 9).add(Duration(minutes: 30 * i)));
    }
    return slots;
  }
}
