import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/app_divider.dart';
import 'package:russian_rock_song_book/app_strings.dart';
import 'package:russian_rock_song_book/order_by.dart';
import 'package:russian_rock_song_book/song_repository.dart';
import 'package:rxdart/rxdart.dart';

import 'app_actions.dart';
import 'app_icons.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'cloud_search_pager.dart';
import 'cloud_song.dart';

class CloudSearchPage extends StatefulWidget {

  final ValueStream<AppState> appStateStream;
  final void Function(AppUIAction action) onPerformAction;

  const CloudSearchPage(
      this.appStateStream,
      this.onPerformAction,
      {super.key});

  @override
  State<StatefulWidget> createState() => _CloudSearchPageState();
}

class _CloudSearchPageState extends State<CloudSearchPage> {

  static const _titleHeight = 75.0;
  static const _dividerHeight = 1.0;
  static const _itemHeight = _titleHeight + _dividerHeight;

  final _cloudSearchTextFieldController = TextEditingController();

  final _cloudTitleScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  OrderBy orderBy = OrderBy.byIdDesc;

  @override
  void initState() {
    super.initState();
    _restoreSearchState(widget.appStateStream.value.cloudState);
  }

  void _scrollToActual(CloudState cloudState) {
    _cloudTitleScrollController.animateTo(cloudState.cloudScrollPosition * _itemHeight,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
    widget.onPerformAction(UpdateCloudSongListNeedScroll(false));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppState>(
        stream: widget.appStateStream,
        builder: (BuildContext context, AsyncSnapshot<AppState> snapshot) {
          final appState = snapshot.data;
          if (appState == null) {
            return const Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  color: AppTheme.colorLightYellow,
                ),
              ),
            );
          }
          return _makePage(context, appState.theme, appState.cloudState);
        }
    );
  }

  Widget _makePage(BuildContext context, AppTheme theme, CloudState cloudState) {
    if (cloudState.needScroll) {
       WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToActual(cloudState));
    }
    return Scaffold(
      backgroundColor: theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: const Text(SongRepository.artistCloudSearch),
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            widget.onPerformAction(Back());
          },
        ),
      ),
      body: Center(
        child:  LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = constraints.maxWidth;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _makeCloudSearchPanel(maxWidth, theme),
              _content(theme, cloudState),
            ],
          );
        }),
      ),
    );
  }

  Widget _content(AppTheme theme, CloudState cloudState) {
    if (cloudState.currentSearchState == SearchState.loading) {
      cloudState.currentSearchPager?.getPage(0, false);
      return _makeProgressIndicator(theme);
    } else if (cloudState.currentSearchState == SearchState.empty) {
      return _makeEmptyListIndicator(theme);
    } else if (cloudState.currentSearchState == SearchState.error) {
      return _makeErrorIndicator(theme);
    } else {
      return Flexible(child: _makeCloudTitleListView(theme, cloudState));
    }
  }

  Widget _makeProgressIndicator(AppTheme theme) => Expanded(
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            color: theme.colorMain,
          ),
        ),
      )
  );

  Widget _makeEmptyListIndicator(AppTheme theme) => Expanded(
      child: Center(
        child: Text(
          AppStrings.strListIsEmpty,
          style: TextStyle(
            color: theme.colorMain,
            fontSize: 24,
          ),
        )
      )
  );

  Widget _makeErrorIndicator(AppTheme theme) => Expanded(
      child: Center(
          child: Text(
            AppStrings.strErrorFetchData,
            style: TextStyle(
              color: theme.colorMain,
              fontSize: 24,
            ),
          )
      )
  );

  Widget _makeCloudSearchPanel(double maxWidth, AppTheme theme) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(4),
      child: Row(
          children: [
            Expanded(
              child: Column(
                  children: [
                    TextField(
                      controller: _cloudSearchTextFieldController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12),
                        fillColor: theme.colorMain,
                        filled: true,
                      ),
                      style: TextStyle(
                        color: theme.colorBg,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: maxWidth - 100,
                      height: 40,
                      child: DropdownButton(
                        value: orderBy.orderByStr,
                        items: orderByDropdownItems(theme),
                        isExpanded: true,
                        onChanged: (String? value) {
                          final orderByStr = value ??
                              OrderBy.byIdDesc.orderByStr;
                          final newOrderBy = OrderByStrings.parseFromString(orderByStr);
                          if (newOrderBy != orderBy) {
                            setState(() {
                              orderBy = newOrderBy;
                            });
                            _performCloudSearch();
                          }
                        },
                        dropdownColor: theme.colorBg,
                      ),
                    ),
                  ]
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            Container(
              width: 88,
              height: 88,
              color: AppTheme.colorDarkYellow,
              child:
              IconButton(
                icon: Image.asset(AppIcons.icCloudSearch),
                padding: const EdgeInsets.all(8),
                onPressed: () {
                  _performCloudSearch();
                },
              ),
            ),
          ],
      ),
    );
  }

  List<DropdownMenuItem<String>> orderByDropdownItems(AppTheme theme) {
    List<DropdownMenuItem<String>> menuItems = OrderBy.values.map((orderBy) =>
        DropdownMenuItem(value: orderBy.orderByStr, child: Text(orderBy.orderByRus, style: TextStyle(color: theme.colorMain)))
    ).toList();

    return menuItems;
  }

  Widget _makeCloudTitleListView(AppTheme theme, CloudState cloudState) => CustomScrollView(
    controller: _cloudTitleScrollController,
    slivers: [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: cloudState.lastPage?.plus(1), (context, pageIndex) {
            return FutureBuilder(
              future: cloudState.currentSearchPager?.getPage(pageIndex, false),
              initialData: null,
              builder: (context, snapshot) {
                final List<Widget> titleViews;
                if (snapshot.data != null) {
                  titleViews = Iterable<int>.generate(
                      snapshot.data?.length ?? 0).map((listIndex) {
                    final cloudSong = snapshot.data!.elementAt(listIndex);
                    final cloudSongIndex = pageIndex * pageSize + listIndex;
                    return _titleItem(theme, cloudState, cloudSong, cloudSongIndex);
                  }).toList();
                  return SizedBox(
                    height: _itemHeight * titleViews.length,
                    child: Column(
                      children: titleViews,
                    ),
                  );
                } else {
                  titleViews = Iterable<int>.generate(pageSize).map((listIndex) {
                    final cloudSongIndex = pageIndex * pageSize + listIndex;
                    return _titleItem(theme, cloudState, null, cloudSongIndex);
                  }).toList();
                }
                return SizedBox(
                  height: _itemHeight * titleViews.length,
                  child: Column(
                    children: titleViews,
                  ),
                );
              },
            );
          }
        ),
      ),
    ],
  );

  Widget _titleItem(AppTheme theme, CloudState cloudState, CloudSong? cloudSong, int cloudSongIndex) {
    final extraLikes;
    final extraDislikes;
    if (cloudSong != null) {
      extraLikes = cloudState.allLikes[cloudSong] ?? 0;
      extraDislikes = cloudState.allDislikes[cloudSong] ?? 0;
    } else {
      extraLikes = 0;
      extraDislikes = 0;
    }

    return GestureDetector(
      onTap: () {
        _backupSearchState();
        widget.onPerformAction(CloudSongClick(cloudSongIndex));
      },
      child: Container(
          height: _itemHeight,
          color: theme.colorBg,
          child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        cloudSong?.artist ?? '',
                        style: TextStyle(
                            color: theme.colorMain)),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                        cloudSong?.visibleTitleWithRating(extraLikes, extraDislikes) ?? '',
                        style: TextStyle(
                            color: theme.colorMain)),
                  ),
                ),
                const Spacer(),
                AppDivider(
                  height: _dividerHeight,
                  color: theme.colorMain,
                )
              ]
          )
      ),
    );
  }

  void _performCloudSearch() {
    _backupSearchState();
    final searchFor = _cloudSearchTextFieldController.text;
    widget.onPerformAction(CloudSearch(searchFor, orderBy));
  }

  void _backupSearchState() {
    final searchFor = _cloudSearchTextFieldController.text;
    widget.onPerformAction(BackupSearchState(searchFor, orderBy));
  }

  void _restoreSearchState(CloudState cloudState) {
    _cloudSearchTextFieldController.text = cloudState.searchForBackup;
    setState(() {
      orderBy = cloudState.orderByBackup;
    });
  }
}
