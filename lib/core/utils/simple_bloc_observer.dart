// lib/core/utils/simple_bloc_observer.dart

import 'package:flutter/foundation.dart'; // Untuk kDebugMode
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    if (kDebugMode) {
      // Cetak hanya dalam mode debug
      debugPrint('onCreate -- ${bloc.runtimeType}');
    }
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      debugPrint('onEvent -- ${bloc.runtimeType}, Event: ${event.runtimeType}');
      // Anda bisa mencetak detail event jika diperlukan:
      // debugPrint('onEvent -- ${bloc.runtimeType}, Event: $event');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      // Cetak currentState dan nextState untuk melihat perubahan
      // Hati-hati jika state object terlalu besar, bisa memenuhi console
      // debugPrint('onChange -- ${bloc.runtimeType}, Change: $change');
      debugPrint('onChange -- ${bloc.runtimeType}');
      debugPrint('  Current State: ${change.currentState.runtimeType}');
      debugPrint('  Next State: ${change.nextState.runtimeType}');
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      // Mirip dengan onChange, tapi spesifik untuk Bloc (bukan Cubit)
      // dan menyertakan event yang menyebabkan transisi.
      // Hati-hati jika state atau event object terlalu besar.
      // debugPrint('onTransition -- ${bloc.runtimeType}, Transition: $transition');
      debugPrint('onTransition -- ${bloc.runtimeType}');
      debugPrint('  Event: ${transition.event.runtimeType}');
      debugPrint('  Current State: ${transition.currentState.runtimeType}');
      debugPrint('  Next State: ${transition.nextState.runtimeType}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    if (kDebugMode) {
      debugPrint('onError -- ${bloc.runtimeType}, Error: $error');
      debugPrint('  StackTrace: $stackTrace');
    }
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    if (kDebugMode) {
      debugPrint('onClose -- ${bloc.runtimeType}');
    }
  }
}
