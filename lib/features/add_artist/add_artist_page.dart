import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/mvi/events/app_events.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';

class AddArtistPage extends StatelessWidget {
  final AppBloc appBloc;
  final void Function(AppUIEvent action) onPerformAction;

  const AddArtistPage(this.appBloc, this.onPerformAction, {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
        bloc: appBloc, // provide the local bloc instance
        builder: (context, state) {
          return _AddArtistPageContent(state.settings, state, onPerformAction);
        }
    );
  }
}

class _AddArtistPageContent extends StatelessWidget {
  final AppSettings settings;
  final AppState appState;
  final void Function(AppUIEvent action) onPerformAction;

  const _AddArtistPageContent(this.settings, this.appState, this.onPerformAction);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settings.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(SongRepository.artistAddArtist, style: settings.textStyler.textStyleFixedBlackBold),
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            onPerformAction(Back());
          },
        ),
      ),
      body: Column(
        children: [
          Text(AppStrings.strAddArtistManual,
              style: settings.textStyler.textStyleSmall),
          const Spacer(),
          TextButton(
            onPressed: () { onPerformAction(AddArtistList()); },
            child: Container(
              color: settings.theme.colorCommon,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(AppStrings.strChoose,
                      style: settings.textStyler.textStyleTitleBlack),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}