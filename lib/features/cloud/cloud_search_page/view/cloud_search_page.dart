import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/data/cloud/cloud_search_pager/cloud_search_pager.dart';
import 'package:russian_rock_song_book/mvi/actions/app_actions.dart';
import 'package:russian_rock_song_book/ui/widgets/app_divider.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/domain/models/cloud/order_by.dart';
import 'package:russian_rock_song_book/data/local/repository/song_repository.dart';
import 'package:rxdart/rxdart.dart';

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

  static double _titleHeight = 110.0;
  static const _dividerHeight = 1.0;
  static double get _itemHeight => _titleHeight + _dividerHeight;

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
            return Container();
          }
          return _makePage(context, appState.settings, appState.cloudState);
        }
    );
  }

  Widget _makePage(BuildContext context, AppSettings settings, CloudState cloudState) {
    _titleHeight = settings.textStyler.fontSizeCommon * 3 + 50;
    if (cloudState.needScroll) {
       WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToActual(cloudState));
    }
    return Scaffold(
      backgroundColor: settings.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(SongRepository.artistCloudSearch, style: settings.textStyler.textStyleFixedBlackBold),
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
              _makeCloudSearchPanel(maxWidth, settings),
              _content(settings, cloudState),
            ],
          );
        }),
      ),
    );
  }

  Widget _content(AppSettings settings, CloudState cloudState) {
    if (cloudState.currentSearchState == SearchState.loading) {
      cloudState.currentSearchPager?.getPage(0, false);
      return _makeProgressIndicator(settings.theme);
    } else if (cloudState.currentSearchState == SearchState.empty) {
      return _makeEmptyListIndicator(settings);
    } else if (cloudState.currentSearchState == SearchState.error) {
      return _makeErrorIndicator(settings);
    } else {
      return Flexible(child: _makeCloudTitleListView(settings, cloudState));
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

  Widget _makeEmptyListIndicator(AppSettings settings) => Expanded(
      child: Center(
        child: Text(
          AppStrings.strListIsEmpty,
          style: settings.textStyler.textStyleTitle,
        )
      )
  );

  Widget _makeErrorIndicator(AppSettings settings) => Expanded(
      child: Center(
          child: Text(
            AppStrings.strErrorFetchData,
            style: settings.textStyler.textStyleTitle,
          )
      )
  );

  Widget _makeCloudSearchPanel(double maxWidth, AppSettings settings) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(4),
      child: Row(
          children: [
            Expanded(
              child: Column(
                  children: [
                    SizedBox(
                      width: maxWidth - 100,
                      height: 48,
                      child:
                      TextField(
                        controller: _cloudSearchTextFieldController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              vertical: (32 - settings.textStyler.fontSizeCommon) / 2),
                          fillColor: settings.theme.colorMain,
                          filled: true,
                        ),
                        style: settings.textStyler.textStyleCommonInverted,
                      ),
                    ),
                    SizedBox(
                      width: maxWidth - 100,
                      height: 40,
                      child: DropdownButton(
                        value: orderBy.orderByStr,
                        items: orderByDropdownItems(settings),
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
                        dropdownColor: settings.theme.colorBg,
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

  List<DropdownMenuItem<String>> orderByDropdownItems(AppSettings settings) {
    List<DropdownMenuItem<String>> menuItems = OrderBy.values.map((orderBy) =>
        DropdownMenuItem(
            value: orderBy.orderByStr,
            child: Text(
              orderBy.orderByRus,
              style: settings.textStyler.textStyleCommon,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ))
    ).toList();

    return menuItems;
  }

  Widget _makeCloudTitleListView(AppSettings settings, CloudState cloudState) => CustomScrollView(
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
                    return _titleItem(settings, cloudState, cloudSong, cloudSongIndex);
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
                    return _titleItem(settings, cloudState, null, cloudSongIndex);
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

  Widget _titleItem(AppSettings settings, CloudState cloudState, CloudSong? cloudSong, int cloudSongIndex) {
    final extraLikes = cloudState.allLikes[cloudSong] ?? 0;
    final extraDislikes = cloudState.allDislikes[cloudSong] ?? 0;

    return GestureDetector(
      onTap: () {
        _backupSearchState();
        widget.onPerformAction(CloudSongClick(cloudSongIndex));
      },
      child: Container(
          height: _itemHeight,
          color: settings.theme.colorBg,
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
                      style: settings.textStyler.textStyleCommon,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                      style: settings.textStyler.textStyleCommon,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Spacer(),
                AppDivider(
                  height: _dividerHeight,
                  color: settings.theme.colorMain,
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
