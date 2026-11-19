import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/clock.dart';
import '../../domain/appointment.dart';
import '../../domain/appointment_repository.dart';

final class AppointmentsState extends Equatable {
  const AppointmentsState({this.all = const [], this.now, this.cancellingId});

  final List<Appointment> all;
  final DateTime? now;
  final String? cancellingId;

  List<Appointment> get upcoming => all
      .where((a) => a.status == AppointmentStatus.upcoming && now != null && a.start.isAfter(now!))
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));

  List<Appointment> get past => all
      .where((a) => !upcoming.contains(a))
      .toList()
    ..sort((a, b) => b.start.compareTo(a.start));

  Appointment? get next => upcoming.isEmpty ? null : upcoming.first;

  AppointmentsState copyWith({List<Appointment>? all, DateTime? now, String? Function()? cancellingId}) =>
      AppointmentsState(
        all: all ?? this.all,
        now: now ?? this.now,
        cancellingId: cancellingId != null ? cancellingId() : this.cancellingId,
      );

  @override
  List<Object?> get props => [all, now, cancellingId];
}

class AppointmentsCubit extends Cubit<AppointmentsState> {
  AppointmentsCubit(this._repository, {Clock clock = const Clock()})
      : _clock = clock,
        super(const AppointmentsState());

  final AppointmentRepository _repository;
  final Clock _clock;
  StreamSubscription<List<Appointment>>? _sub;

  void start() {
    _sub ??= _repository.watchAppointments().listen(
          (items) => emit(state.copyWith(all: items, now: _clock.now())),
        );
  }

  Future<void> cancel(String id) async {
    emit(state.copyWith(cancellingId: () => id));
    await _repository.cancel(id);
    emit(state.copyWith(cancellingId: () => null));
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
