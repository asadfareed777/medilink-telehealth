import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/doctor.dart';
import '../../domain/doctor_repository.dart';

// ---------- Events ----------
sealed class DoctorsEvent extends Equatable {
  const DoctorsEvent();
  @override
  List<Object?> get props => [];
}

final class DoctorsRequested extends DoctorsEvent {
  const DoctorsRequested();
}

final class SpecialtyToggled extends DoctorsEvent {
  const SpecialtyToggled(this.specialty);
  final Specialty specialty;
  @override
  List<Object?> get props => [specialty];
}

final class SearchChanged extends DoctorsEvent {
  const SearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

// ---------- State ----------
enum DoctorsStatus { initial, loading, success, failure }

final class DoctorsState extends Equatable {
  const DoctorsState({
    this.status = DoctorsStatus.initial,
    this.doctors = const [],
    this.specialty,
    this.query = '',
  });

  final DoctorsStatus status;
  final List<Doctor> doctors;
  final Specialty? specialty;
  final String query;

  /// Doctors after applying the specialty filter and the search query.
  List<Doctor> get visible {
    final q = query.trim().toLowerCase();
    return doctors.where((d) {
      final matchesSpecialty = specialty == null || d.specialty == specialty;
      final matchesQuery = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.specialty.label.toLowerCase().contains(q) ||
          d.hospital.toLowerCase().contains(q);
      return matchesSpecialty && matchesQuery;
    }).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  DoctorsState copyWith({
    DoctorsStatus? status,
    List<Doctor>? doctors,
    Specialty? Function()? specialty,
    String? query,
  }) =>
      DoctorsState(
        status: status ?? this.status,
        doctors: doctors ?? this.doctors,
        specialty: specialty != null ? specialty() : this.specialty,
        query: query ?? this.query,
      );

  @override
  List<Object?> get props => [status, doctors, specialty, query];
}

// ---------- Bloc ----------
class DoctorsBloc extends Bloc<DoctorsEvent, DoctorsState> {
  DoctorsBloc(this._repository) : super(const DoctorsState()) {
    on<DoctorsRequested>(_onRequested);
    on<SpecialtyToggled>(_onSpecialtyToggled);
    on<SearchChanged>(_onSearchChanged);
  }

  final DoctorRepository _repository;

  Future<void> _onRequested(DoctorsRequested event, Emitter<DoctorsState> emit) async {
    emit(state.copyWith(status: DoctorsStatus.loading));
    try {
      final doctors = await _repository.getDoctors();
      emit(state.copyWith(status: DoctorsStatus.success, doctors: doctors));
    } catch (_) {
      emit(state.copyWith(status: DoctorsStatus.failure));
    }
  }

  void _onSpecialtyToggled(SpecialtyToggled event, Emitter<DoctorsState> emit) {
    final next = state.specialty == event.specialty ? null : event.specialty;
    emit(state.copyWith(specialty: () => next));
  }

  void _onSearchChanged(SearchChanged event, Emitter<DoctorsState> emit) {
    emit(state.copyWith(query: event.query));
  }
}
