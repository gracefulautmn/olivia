import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:olivia/core/errors/failures.dart';
import 'package:olivia/features/item/domain/entities/item.dart';
import 'package:olivia/features/item/domain/usecases/search_items.dart';

part 'my_reports_event.dart';
part 'my_reports_state.dart';

class MyReportsBloc extends Bloc<MyReportsEvent, MyReportsState> {
  final SearchItems _searchItemsUseCase;

  MyReportsBloc(this._searchItemsUseCase) : super(MyReportsInitial()) {
    on<LoadMyReports>(_onLoadMyReports);
  }

  Future<void> _onLoadMyReports(
    LoadMyReports event,
    Emitter<MyReportsState> emit,
  ) async {
    emit(MyReportsLoading());
    // Panggil use case hanya dengan filter reporterId, tanpa filter lain
    final result = await _searchItemsUseCase(SearchItemsParams(
      reporterId: event.userId,
    ));
    result.fold(
      (failure) => emit(MyReportsFailure(failure.message)),
      (items) => emit(MyReportsLoaded(items)),
    );
  }
}