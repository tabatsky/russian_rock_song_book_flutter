import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/mvi/events/app_events.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/mvi/state/local_state.dart';
import 'package:russian_rock_song_book/ui/font/app_font.dart';
import 'package:russian_rock_song_book/ui/widgets/app_divider.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';

class SongListPage extends StatelessWidget{
  final AppBloc appBloc;
  final void Function(AppUIEvent action) onPerformAction;

  const SongListPage(
      this.appBloc,
      this.onPerformAction,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
        bloc: appBloc, // provide the local bloc instance
        builder: (context, state) {
          return _SongListPageContent(state.settings, state.localState, onPerformAction);
        }
    );
  }
}

class _SongListPageContent extends StatefulWidget {
  final AppSettings settings;
  final LocalState localState;
  final void Function(AppUIEvent action) onPerformAction;

  const _SongListPageContent(this.settings, this.localState, this.onPerformAction);


  @override
  State<StatefulWidget> createState() => _SongListPageContentState();
}

class _SongListPageContentState extends State<_SongListPageContent> {
  static double _titleHeight = 50.0;
  static const _dividerHeight = 1.0;
  static double get _itemHeight => _titleHeight + _dividerHeight;

  final _menuScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );
  double _menuScrollOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    _titleHeight = widget.settings.textStyler.fontSizeCommon * 1.5 + 20;
    return Scaffold(
      backgroundColor: widget.settings.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(
          widget.localState.currentArtist,
          style: widget.settings.textStyler.textStyleFixedBlackBold,
          key: const Key('song_list_title'),
        ),
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
        child: _MenuListView(
            widget.settings,
            widget.localState,
            _menuScrollController,
            _titleHeight,
            _dividerHeight,
            widget.onPerformAction),
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
            _SongListBody(widget.settings, widget.localState, _titleHeight, _dividerHeight, _itemHeight, widget.onPerformAction),
          ],
        ),
      ),
    );
  }
}

class _MenuListView extends StatelessWidget {
  final AppSettings settings;
  final LocalState localState;
  final ScrollController menuScrollController;
  final double titleHeight;
  final double dividerHeight;
  final void Function(AppUIEvent action) onPerformAction;

  const _MenuListView(this.settings, this.localState, this.menuScrollController, this.titleHeight, this.dividerHeight, this.onPerformAction);

  @override
  Widget build(BuildContext context) {
    final predefinedWithGroups = localState.allArtists.predefinedArtistsWithGroups();
    return ListView.builder(
        key: const Key('menu_list_view'),
        controller: menuScrollController,
        padding: EdgeInsets.zero,
        itemCount: predefinedWithGroups.length + 1,
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
            final artistOrGroup = predefinedWithGroups[index - 1];
            return _MenuItem(
                artistOrGroup: artistOrGroup,
                artistList: SongRepository.predefinedArtists + localState.allArtists,
                menuExpandedArtistGroup: localState.menuExpandedArtistGroup,
                theme: settings.theme,
                textStyler: settings.textStyler,
                titleHeight: titleHeight,
                dividerHeight: dividerHeight,
                onGroupTap: () {
                  onPerformAction(UpdateMenuExpandedArtistGroup(artistOrGroup));
                },
                onArtistTap: (artist) {
                  Navigator.pop(context);
                  onPerformAction(ArtistClick(artist));
                }
            );
          }
        }
    );
  }
}

class _MenuItem extends StatelessWidget {
  final String artistOrGroup;
  final List<String> artistList;
  final String menuExpandedArtistGroup;
  final AppTheme theme;
  final AppTextStyler textStyler;
  final double titleHeight;
  final double dividerHeight;
  final void Function() onGroupTap;
  final void Function(String artist) onArtistTap;

  const _MenuItem({required this.artistOrGroup, required this.artistList, required this.menuExpandedArtistGroup, required this.theme, required this.textStyler, required this.titleHeight, required this.dividerHeight, required this.onGroupTap, required this.onArtistTap});

  @override
  Widget build(BuildContext context) {
    return SongRepository.predefinedArtists.contains(artistOrGroup) ?
        _ArtistItem(
            artist: artistOrGroup,
            theme: theme,
            textStyler: textStyler,
            titleHeight: titleHeight,
            dividerHeight: dividerHeight,
            onTap: () => onArtistTap(artistOrGroup)
        ) :
        _ArtistGroupItem(
            artistGroup: artistOrGroup,
            expandedList: _getExpandedList(artistOrGroup),
            theme: theme,
            textStyler: textStyler,
            titleHeight: titleHeight,
            dividerHeight: dividerHeight,
            onGroupTap: onGroupTap,
            onArtistTap: onArtistTap
        );
  }

  List<String> _getExpandedList(String group) => group == menuExpandedArtistGroup ?
      artistList.where((element) =>
        !SongRepository.predefinedArtists.contains(element) &&
        element.toUpperCase().startsWith(group)
      ).toList() : [];

}

class _ArtistGroupItem extends StatelessWidget {
  final String artistGroup;
  final List<String> expandedList;
  final AppTheme theme;
  final AppTextStyler textStyler;
  final double titleHeight;
  final double dividerHeight;
  final void Function() onGroupTap;
  final void Function(String artist) onArtistTap;

  const _ArtistGroupItem({required this.artistGroup, required this.expandedList, required this.theme, required this.textStyler, required this.titleHeight, required this.dividerHeight, required this.onGroupTap, required this.onArtistTap});

  @override
  Widget build(BuildContext context) {
    final children1 = [
      GestureDetector(
        onTap: onGroupTap,
        child: Container(
          height: titleHeight,
          color: theme.colorMain,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                artistGroup,
                style: textStyler.textStyleCommonInvertedW500,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
      AppDivider(
        height: dividerHeight,
        color: theme.colorBg,
      ),
    ];
    final children2 = expandedList.map((artist) =>
      _ArtistItem(
          artist: artist,
          theme: theme,
          textStyler: textStyler,
          titleHeight: titleHeight,
          dividerHeight: dividerHeight,
          onTap: () => onArtistTap(artist)
      )
    ).toList();
    final children = children1 + children2;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Column(children: children),
    );
  }
}

class _ArtistItem extends StatelessWidget {
  final String artist;
  final AppTheme theme;
  final AppTextStyler textStyler;
  final double titleHeight;
  final double dividerHeight;
  final void Function() onTap;

  const _ArtistItem({required this.artist, required this.theme, required this.textStyler, required this.titleHeight, required this.dividerHeight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textStyle =
    SongRepository.predefinedArtists.contains(artist)
        ? textStyler.textStyleCommonInvertedBold
        : textStyler.textStyleCommonInverted;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: titleHeight,
            color: theme.colorMain,
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
          height: dividerHeight,
          color: theme.colorBg,
        ),
      ],
    );
  }

}

class _SongListBody extends StatelessWidget {
  final AppSettings settings;
  final LocalState localState;
  final double titleHeight;
  final double dividerHeight;
  final double itemHeight;
  final void Function(AppUIEvent action) onPerformAction;

  final _titleScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  _SongListBody(this.settings, this.localState, this.titleHeight, this.dividerHeight, this.itemHeight, this.onPerformAction);

  @override
  Widget build(BuildContext context) {
    if (localState.currentSongs.isEmpty) {
      return _EmptyListIndicator(settings);
    } else {
      WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToActual(localState));
      return Flexible(child: _TitleListView(
          settings,
          localState,
          _titleScrollController,
          titleHeight,
          dividerHeight,
          onPerformAction
      ));
    }
  }

  void _scrollToActual(LocalState localState) {
    _titleScrollController.animateTo(localState.scrollPosition * itemHeight,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

}

class _TitleListView extends StatelessWidget {
  final AppSettings settings;
  final LocalState localState;
  final ScrollController titleScrollController;
  final double titleHeight;
  final double dividerHeight;
  final void Function(AppUIEvent action) onPerformAction;

  const _TitleListView(this.settings, this.localState, this.titleScrollController, this.titleHeight, this.dividerHeight, this.onPerformAction);

  @override
  Widget build(BuildContext context) => ListView.builder(
      key: const Key('title_list_view'),
      controller: titleScrollController,
      padding: EdgeInsets.zero,
      itemCount: localState.currentSongs.length,
      itemBuilder: (BuildContext context, int index) {
        final song = localState.currentSongs[index];
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                onPerformAction(SongClick(index));
              },
              child: Container(
                  height: titleHeight,
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
              height: dividerHeight,
              color: settings.theme.colorMain,
            )
          ],
        );
      }
  );
}

class _EmptyListIndicator extends StatelessWidget {
  final AppSettings settings;

  const _EmptyListIndicator(this.settings);

  @override
  Widget build(BuildContext context) => Expanded(
      child: Center(
          child: Text(
            AppStrings.strListIsEmpty,
            style: settings.textStyler.textStyleTitle,
          )
      )
  );
}