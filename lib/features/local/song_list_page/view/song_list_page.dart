import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:russian_rock_song_book/mvi/actions/app_actions.dart';
import 'package:russian_rock_song_book/ui/widgets/app_divider.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/data/local/repository/song_repository.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:rxdart/rxdart.dart';

class SongListPage extends StatefulWidget{
  final ValueStream<AppState> appStateStream;
  final void Function(AppUIAction action) onPerformAction;

  const SongListPage(
      this.appStateStream,
      this.onPerformAction,
      {super.key});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage> {

  static double _titleHeight = 50.0;
  static const _dividerHeight = 1.0;
  static double get _itemHeight => _titleHeight + _dividerHeight;

  final _titleScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  final _menuScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  double _menuScrollOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppState>(
        stream: widget.appStateStream,
        builder: (BuildContext context, AsyncSnapshot<AppState> snapshot) {
          final appState = snapshot.data;
          if (appState == null) {
            return Container();
          }
          return _makePage(context, appState.settings, appState.localState);
        }
    );
  }

  void _scrollToActual(LocalState localState) {
    _titleScrollController.animateTo(localState.scrollPosition * _itemHeight,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  Widget _makePage(BuildContext context, AppSettings settings, LocalState localState) {
    _titleHeight = settings.textStyler.fontSizeCommon * 1.5 + 20;
    return Scaffold(
      backgroundColor: settings.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(localState.currentArtist, style: settings.textStyler.textStyleFixedBlackBold),
        actions: [
          IconButton(
            icon: Image.asset(AppIcons.icSettings),
            iconSize: 50,
            onPressed: () {
              widget.onPerformAction(OpenSettings());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: _makeMenuListView(settings, localState),
      ),
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _menuScrollController.animateTo(_menuScrollOffset,
                duration: const Duration(milliseconds: 1), curve: Curves.ease);
          });
        } else {
          _menuScrollOffset = _menuScrollController.position.pixels;
        }
      },
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _makeContent(settings, localState),
          ],
        ),
      ),
    );
  }

  ListView _makeMenuListView(AppSettings settings, LocalState localState) => ListView.builder(
      controller: _menuScrollController,
      padding: EdgeInsets.zero,
      itemCount: localState.allArtists.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.colorDarkYellow,
              ),
              margin: EdgeInsets.zero,
              child: Text(AppStrings.strMenu, style: settings.textStyler.textStyleFixedBlackBold),
            ),
          );
        } else {
          final artist = localState.allArtists[index - 1];
          final textStyle =
            SongRepository.predefinedArtists.contains(artist)
                ? settings.textStyler.textStyleCommonInvertedBold
                : settings.textStyler.textStyleCommonInverted;
          return Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  widget.onPerformAction(ArtistClick(artist));
                },
                child: Container(
                  height: _titleHeight,
                  color: settings.theme.colorMain,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        artist,
                        style: textStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              AppDivider(
                height: _dividerHeight,
                color: settings.theme.colorBg,
              ),
            ],
          );
        }
      }
  );

  Widget _makeContent(AppSettings settings, LocalState localState) {
    if (localState.currentSongs.isEmpty) {
      return _makeEmptyListIndicator(settings);
    } else {
      WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToActual(localState));
      return Flexible(child: _makeTitleListView(settings, localState));
    }
  }

  Widget _makeEmptyListIndicator(AppSettings settings) => Expanded(
      child: Center(
          child: Text(
            AppStrings.strListIsEmpty,
            style: settings.textStyler.textStyleTitle,
          )
      )
  );

  ListView _makeTitleListView(AppSettings settings, LocalState localState) => ListView.builder(
      controller: _titleScrollController,
      padding: EdgeInsets.zero,
      itemCount: localState.currentSongs.length,
      itemBuilder: (BuildContext context, int index) {
        final song = localState.currentSongs[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                widget.onPerformAction(SongClick(index));
              },
              child: Container(
                  height: _titleHeight,
                  color: settings.theme.colorBg,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        song.title,
                        style: settings.textStyler.textStyleCommon,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
              ),
            ),
            AppDivider(
              height: _dividerHeight,
              color: settings.theme.colorMain,
            )
          ],
        );
      }
  );
}