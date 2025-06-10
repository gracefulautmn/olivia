import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/core/usecases/usecase.dart';
import 'package:olivia/features/history/domain/entities/claim_history_entry.dart';
import 'package:olivia/features/history/domain/usecases/get_global_claim_history.dart';

part 'global_history_event.dart';
part 'global_history_state.dart';

class GlobalHistoryBloc extends Bloc<GlobalHistoryEvent, GlobalHistoryState> {
  final GetGlobalClaimHistory _getGlobalClaimHistory;

  GlobalHistoryBloc(this._getGlobalClaimHistory) : super(GlobalHistoryInitial()) {
    on<LoadGlobalHistory>(_onLoadGlobalHistory);
  }

  Future<void> _onLoadGlobalHistory(
    LoadGlobalHistory event,
    Emitter<GlobalHistoryState> emit,
  ) async {
    emit(GlobalHistoryLoading());
    final result = await _getGlobalClaimHistory(NoParams());
    result.fold(
      (failure) => emit(GlobalHistoryFailure(failure.message)),
      (historyEntries) => emit(GlobalHistoryLoaded(historyEntries)),
    );
  }
}