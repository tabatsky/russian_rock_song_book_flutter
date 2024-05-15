import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russian_rock_song_book/mvi/actions/app_actions.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';

class AppBloc extends Bloc<AppUIAction, AppState> {
  final AppStateMachine appStateMachine;

  /// The initial state of the `CounterBloc` is 0.
  AppBloc(this.appStateMachine) : super(AppState()) {
    /// When a `CounterIncrementPressed` event is added,
    /// the current `state` of the bloc is accessed via the `state` property
    /// and a new state is emitted via `emit`.
    on<AppUIAction>((event, emit) async {
      final machineAcceptedAction = await appStateMachine.performAction((newState) async {
        log('emit');
        final newStateCopy = newState.copy();
        emit(newStateCopy);
      }, state, event);

      if (machineAcceptedAction) {
        log('app state machine accepted action from bloc');
      }
    });
  }
}