part of 'manual_claim_bloc.dart';

abstract class ManualClaimEvent extends Equatable {
  const ManualClaimEvent();

  @override
  List<Object> get props => [];
}

class FetchAvailableItems extends ManualClaimEvent {}

class SubmitClaimButtonPressed extends ManualClaimEvent {
  final String itemId;
  final UserProfile securityUser;
  final String guestDetails;

  const SubmitClaimButtonPressed({
    required this.itemId,
    required this.securityUser,
    required this.guestDetails,
  });

  @override
  List<Object> get props => [itemId, securityUser, guestDetails];
}