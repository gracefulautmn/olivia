import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/auth/domain/entities/user_profile.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/search_items.dart';
import 'package:olivia/features/item/domain/usecases/submit_guest_claim.dart';

part 'manual_claim_event.dart';
part 'manual_claim_state.dart';

class ManualClaimBloc extends Bloc<ManualClaimEvent, ManualClaimState> {
  final SearchItems searchItems;
  final SubmitGuestClaim submitGuestClaim;

  ManualClaimBloc({required this.searchItems, required this.submitGuestClaim})
      : super(ManualClaimInitial()) {
    on<FetchAvailableItems>(_onFetchAvailableItems);
    on<SubmitClaimButtonPressed>(_onSubmitClaimButtonPressed);
  }

  Future<void> _onFetchAvailableItems(
    FetchAvailableItems event,
    Emitter<ManualClaimState> emit,
  ) async {
    emit(ManualClaimLoading());
    final result = await searchItems(const SearchItemsParams(
      status: 'ditemukan_tersedia', // Hanya ambil item yang tersedia
      reportType: 'penemuan',
    ));
    result.fold(
      (failure) => emit(ManualClaimLoadFailure(failure.message)),
      (items) => emit(ManualClaimLoadSuccess(items)),
    );
  }

  Future<void> _onSubmitClaimButtonPressed(
    SubmitClaimButtonPressed event,
    Emitter<ManualClaimState> emit,
  ) async {
    // Pertahankan daftar item saat memproses
    final currentState = state;
    List<ItemEntity> currentItems = [];
    if (currentState is ManualClaimLoadSuccess) {
      currentItems = currentState.availableItems;
    }

    emit(ManualClaimSubmitting(availableItems: currentItems));

    final result = await submitGuestClaim(SubmitGuestClaimParams(
      itemId: event.itemId,
      securityId: event.securityUser.id,
      guestDetails: event.guestDetails,
    ));

    result.fold(
      (failure) => emit(ManualClaimSubmitFailure(failure.message, availableItems: currentItems)),
      (_) => emit(ManualClaimSubmitSuccess()),
    );
  }
}
