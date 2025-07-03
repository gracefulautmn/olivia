part of 'my_reports_bloc.dart';

abstract class MyReportsEvent extends Equatable {
  const MyReportsEvent();
  @override
  List<Object> get props => [];
}

class LoadMyReports extends MyReportsEvent {
  final String userId;
  const LoadMyReports({required this.userId});
  @override
  List<Object> get props => [userId];
}