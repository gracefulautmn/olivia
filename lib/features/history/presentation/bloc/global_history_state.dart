part of 'global_history_bloc.dart';

abstract class GlobalHistoryState extends Equatable {
  const GlobalHistoryState();

  @override
  List<Object> get props => [];
}

class GlobalHistoryInitial extends GlobalHistoryState {}

class GlobalHistoryLoading extends GlobalHistoryState {}

class GlobalHistoryLoaded extends GlobalHistoryState {
  final List<ClaimHistoryEntry> historyEntries;

  const GlobalHistoryLoaded(this.historyEntries);

  @override
  List<Object> get props => [historyEntries];
}

class GlobalHistoryFailure extends GlobalHistoryState {
  final String message;

  const GlobalHistoryFailure(this.message);

  @override
  List<Object> get props => [message];
}