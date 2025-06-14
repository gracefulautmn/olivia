import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/features/feedback/domain/entities/feedback.dart';
import 'package:olivia/features/feedback/domain/usecases/submit_feedback.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final SubmitFeedback _submitFeedback;

  FeedbackBloc(this._submitFeedback) : super(FeedbackInitial()) {
    on<FeedbackSubmitted>(_onFeedbackSubmitted);
  }

  Future<void> _onFeedbackSubmitted(
    FeedbackSubmitted event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackSubmitting());
    final result = await _submitFeedback(event.feedback);
    result.fold(
      (failure) => emit(FeedbackFailure(failure.message)),
      (_) => emit(FeedbackSuccess()),
    );
  }
}




