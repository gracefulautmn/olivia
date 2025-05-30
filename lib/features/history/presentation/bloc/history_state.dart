part of 'history_bloc.dart';

enum HistoryStatus { initial, loading, loaded, failure }

class HistoryState extends Equatable {
  final HistoryStatus status;
  final List<ItemEntity> claimedItems; // Item yang sudah diklaim
  final Failure? failure;
  final bool viewingAsClaimer; // Untuk menandai tab mana yang aktif

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.claimedItems = const [],
    this.failure,
    this.viewingAsClaimer = true,
  });

  HistoryState copyWith({
    HistoryStatus? status,
    List<ItemEntity>? claimedItems,
    Failure? failure,
    bool? viewingAsClaimer,
    bool clearFailure = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      claimedItems: claimedItems ?? this.claimedItems,
      failure: clearFailure ? null : failure ?? this.failure,
      viewingAsClaimer: viewingAsClaimer ?? this.viewingAsClaimer,
    );
  }

  @override
  List<Object?> get props => [status, claimedItems, failure, viewingAsClaimer];
}