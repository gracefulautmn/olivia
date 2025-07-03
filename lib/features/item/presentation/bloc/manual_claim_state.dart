part of 'manual_claim_bloc.dart';

abstract class ManualClaimState extends Equatable {
  const ManualClaimState();

  @override
  List<Object> get props => [];
}

class ManualClaimInitial extends ManualClaimState {}

class ManualClaimLoading extends ManualClaimState {}

class ManualClaimLoadSuccess extends ManualClaimState {
  final List<ItemEntity> availableItems;

  const ManualClaimLoadSuccess(this.availableItems);

  @override
  List<Object> get props => [availableItems];
}

class ManualClaimLoadFailure extends ManualClaimState {
  final String message;

  const ManualClaimLoadFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ManualClaimSubmitting extends ManualClaimLoadSuccess {
  const ManualClaimSubmitting({required List<ItemEntity> availableItems})
      : super(availableItems);
}

class ManualClaimSubmitSuccess extends ManualClaimState {}

class ManualClaimSubmitFailure extends ManualClaimLoadSuccess {
    final String message;

    const ManualClaimSubmitFailure(this.message, {required List<ItemEntity> availableItems})
      : super(availableItems);

    @override
    List<Object> get props => [message, availableItems];
}
