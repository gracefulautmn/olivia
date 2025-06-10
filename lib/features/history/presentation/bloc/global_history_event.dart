part of 'global_history_bloc.dart';

abstract class GlobalHistoryEvent extends Equatable {
  const GlobalHistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadGlobalHistory extends GlobalHistoryEvent {}