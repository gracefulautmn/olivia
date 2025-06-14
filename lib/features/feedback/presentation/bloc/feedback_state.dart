part of 'feedback_bloc.dart';

abstract class FeedbackState extends Equatable {
  const FeedbackState();
  @override
  List<Object> get props => [];
}

class FeedbackInitial extends FeedbackState {}
class FeedbackSubmitting extends FeedbackState {}
class FeedbackSuccess extends FeedbackState {}
class FeedbackFailure extends FeedbackState {
  final String message;
  const FeedbackFailure(this.message);
  @override
  List<Object> get props => [message];
}