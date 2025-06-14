part of 'feedback_bloc.dart';

abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();
  @override
  List<Object> get props => [];
}

class FeedbackSubmitted extends FeedbackEvent {
  final FeedbackEntity feedback;
  const FeedbackSubmitted(this.feedback);
  @override
  List<Object> get props => [feedback];
}