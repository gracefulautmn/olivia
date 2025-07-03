part of 'my_reports_bloc.dart';

abstract class MyReportsState extends Equatable {
  const MyReportsState();
  @override
  List<Object> get props => [];
}

class MyReportsInitial extends MyReportsState {}
class MyReportsLoading extends MyReportsState {}
class MyReportsLoaded extends MyReportsState {
  final List<ItemEntity> myItems;
  const MyReportsLoaded(this.myItems);
  @override
  List<Object> get props => [myItems];
}
class MyReportsFailure extends MyReportsState {
  final String message;
  const MyReportsFailure(this.message);
  @override
  List<Object> get props => [message];
}