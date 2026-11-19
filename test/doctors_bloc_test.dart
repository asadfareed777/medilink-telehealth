import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medilink/features/doctors/data/fake_doctor_repository.dart';
import 'package:medilink/features/doctors/domain/doctor.dart';
import 'package:medilink/features/doctors/domain/doctor_repository.dart';
import 'package:medilink/features/doctors/presentation/bloc/doctors_bloc.dart';
import 'package:mocktail/mocktail.dart';

class _MockDoctorRepository extends Mock implements DoctorRepository {}

void main() {
  final doctors = FakeDoctorRepository.doctors;

  group('DoctorsBloc', () {
    late DoctorRepository repository;

    setUp(() {
      repository = _MockDoctorRepository();
      when(() => repository.getDoctors()).thenAnswer((_) async => doctors);
    });

    blocTest<DoctorsBloc, DoctorsState>(
      'emits loading then success with doctors',
      build: () => DoctorsBloc(repository),
      act: (bloc) => bloc.add(const DoctorsRequested()),
      expect: () => [
        const DoctorsState(status: DoctorsStatus.loading),
        DoctorsState(status: DoctorsStatus.success, doctors: doctors),
      ],
    );

    blocTest<DoctorsBloc, DoctorsState>(
      'emits failure when repository throws',
      setUp: () => when(() => repository.getDoctors()).thenThrow(Exception('offline')),
      build: () => DoctorsBloc(repository),
      act: (bloc) => bloc.add(const DoctorsRequested()),
      expect: () => [
        const DoctorsState(status: DoctorsStatus.loading),
        const DoctorsState(status: DoctorsStatus.failure),
      ],
    );

    blocTest<DoctorsBloc, DoctorsState>(
      'toggling the same specialty twice clears the filter',
      build: () => DoctorsBloc(repository),
      seed: () => DoctorsState(status: DoctorsStatus.success, doctors: doctors),
      act: (bloc) => bloc
        ..add(const SpecialtyToggled(Specialty.cardiology))
        ..add(const SpecialtyToggled(Specialty.cardiology)),
      expect: () => [
        DoctorsState(status: DoctorsStatus.success, doctors: doctors, specialty: Specialty.cardiology),
        DoctorsState(status: DoctorsStatus.success, doctors: doctors),
      ],
    );
  });

  group('DoctorsState.visible', () {
    final base = DoctorsState(status: DoctorsStatus.success, doctors: doctors);

    test('filters by specialty', () {
      final visible = base.copyWith(specialty: () => Specialty.pediatrics).visible;
      expect(visible.map((d) => d.id), ['d3']);
    });

    test('search matches name, specialty and hospital case-insensitively', () {
      expect(base.copyWith(query: 'chen').visible.single.id, 'd2');
      expect(base.copyWith(query: 'NEURO').visible.single.id, 'd4');
      expect(base.copyWith(query: 'shifa').visible.single.id, 'd1');
    });

    test('results are sorted by rating, highest first', () {
      final ratings = base.visible.map((d) => d.rating).toList();
      final sorted = [...ratings]..sort((a, b) => b.compareTo(a));
      expect(ratings, sorted);
    });
  });
}
