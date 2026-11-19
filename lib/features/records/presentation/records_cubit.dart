import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/health_summary.dart';

sealed class RecordsState {
  const RecordsState();
}

final class RecordsLoading extends RecordsState {
  const RecordsLoading();
}

final class RecordsLoaded extends RecordsState {
  const RecordsLoaded(this.summary);
  final HealthSummary summary;
}

final class RecordsError extends RecordsState {
  const RecordsError();
}

class RecordsCubit extends Cubit<RecordsState> {
  RecordsCubit(this._repository) : super(const RecordsLoading());

  final RecordsRepository _repository;

  Future<void> load() async {
    emit(const RecordsLoading());
    try {
      emit(RecordsLoaded(await _repository.getSummary()));
    } catch (_) {
      emit(const RecordsError());
    }
  }
}
