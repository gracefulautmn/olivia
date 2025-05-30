part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadClaimedHistory extends HistoryEvent {
  final String userId;
  final bool asClaimer; // true: barang yg dia klaim, false: barang yg dia temukan dan diklaim orang
  final bool refresh;

  const LoadClaimedHistory({
    required this.userId,
    this.asClaimer = true, // Default menampilkan barang yang dia klaim
    this.refresh = false,
  });

  @override
  List<Object> get props => [userId, asClaimer, refresh];
}