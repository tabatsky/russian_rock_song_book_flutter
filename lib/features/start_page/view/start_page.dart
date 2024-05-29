import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/data/settings/version.dart';

class StartPage extends StatefulWidget {

  final AppBloc appBloc;
  final void Function() onInitSuccess;

  const StartPage(this.appBloc, this.onInitSuccess, {super.key});

  @override
  State<StatefulWidget> createState() => StartPageState();

}

class StartPageState extends State<StartPage> {

  double indicatorValue = 0.0;
  String indicatorText = AppStrings.strFrom(0, SongRepository.artistMap.length);
  bool wasUpdated = false;

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
        bloc: widget.appBloc, // provide the local bloc instance
        builder: (context, state) {
          return _makePage(context, state.settings);
        }
    );
  }

  Widget _makePage(BuildContext context, AppSettings settings) {
    return Material(
      color: settings.theme.colorBg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: wasUpdated ? [
          Text(AppStrings.strStartPleaseWait,
              style: settings.textStyler.textStyleSmallTitle),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: LinearProgressIndicator(
              value: indicatorValue,
              minHeight: 30,
              backgroundColor: AppTheme.colorDarkYellow,
              color: settings.theme.colorMain,
            ),
          ),
          Text(indicatorText, style: settings.textStyler.textStyleSmallTitle),
          const SizedBox(
            height: 30,
          ),
          Text(AppStrings.strStartDbBuilding,
              style: settings.textStyler.textStyleSmall),
        ] : [
          Text(AppStrings.strStartPleaseWait,
              style: settings.textStyler.textStyleSmallTitle),
        ],
      ),
    );
  }

  Future<void> _initDB() async {
    await GetIt.I<SongRepository>().initDB();
    final appWasUpdated = await Version.appWasUpdated();
    setState(() {
      wasUpdated = appWasUpdated;
    });
    if (appWasUpdated) {
      print('was updated');
      await GetIt.I<SongRepository>().fillDB((done, total) {
        print("done: $done of $total");
        if (mounted) {
          setState(() {
            indicatorValue = 1.0 * done / total;
            indicatorText = AppStrings.strFrom(done, total);
          });
        }
      });
      await Version.confirmAppUpdate();
    } else {
      print('was not updated');
    }
    widget.onInitSuccess();
  }
}