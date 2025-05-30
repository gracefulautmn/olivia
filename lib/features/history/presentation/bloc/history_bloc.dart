import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/get_claimed_items_history.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetClaimedItemsHistory _getClaimedItemsHistoryUseCase;

  HistoryBloc({required GetClaimedItemsHistory getClaimedItemsHistoryUseCase})
      : _getClaimedItemsHistoryUseCase = getClaimedItemsHistoryUseCase,
        super(const HistoryState()) {
    on<LoadClaimedHistory>(_onLoadClaimedHistory);
  }

  Future<void> _onLoadClaimedHistory(
    LoadClaimedHistory event,
    Emitter<HistoryState> emit,
  ) async {
    // Jika tab berubah, reset list dulu agar tidak ada sisa data dari tab sebelumnya
    if (state.viewingAsClaimer != event.asClaimer || event.refresh) {
      emit(state.copyWith(
        status: HistoryStatus.loading, 
        claimedItems: [], 
        viewingAsClaimer: event.asClaimer, 
        clearFailure: true
      ));
    } else {
      emit(state.copyWith(status: HistoryStatus.loading, viewingAsClaimer: event.asClaimer, clearFailure: true));
    }

    final result = await _getClaimedItemsHistoryUseCase(
      GetClaimedItemsHistoryParams(userId: event.userId, asClaimer: event.asClaimer),
    );

    result.fold(
      (failure) => emit(state.copyWith(status: HistoryStatus.failure, failure: failure)),
      (items) => emit(state.copyWith(status: HistoryStatus.loaded, claimedItems: items)),
    );
  }
}