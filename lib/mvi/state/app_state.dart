import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/mvi/state/cloud_state.dart';
import 'package:russian_rock_song_book/mvi/state/local_state.dart';
import 'package:russian_rock_song_book/mvi/state/page_variant.dart';

class AppState {
  PageVariant currentPageVariant = PageVariant.start;

  AppSettings settings = AppSettings();
  LocalState localState = LocalState();
  CloudState cloudState = CloudState();

  AppState();

  AppState._newInstance(
      this.currentPageVariant,
      this.settings,
      this.localState,
      this.cloudState
      );

  AppState copy() => AppState._newInstance(
      currentPageVariant,
      settings.copy(),
      localState.copy(),
      cloudState.copy()
  );
}
