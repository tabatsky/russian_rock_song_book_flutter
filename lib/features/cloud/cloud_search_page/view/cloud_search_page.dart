import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:russian_rock_song_book/data/cloud/cloud_search_pager/cloud_search_pager.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/mvi/events/app_events.dart';
import 'package:russian_rock_song_book/mvi/bloc/app_bloc.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/mvi/state/cloud_state.dart';
import 'package:russian_rock_song_book/test/test_keys.dart';
import 'package:russian_rock_song_book/ui/widgets/app_divider.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:russian_rock_song_book/domain/models/cloud/cloud_song.dart';
import 'package:russian_rock_song_book/domain/models/cloud/order_by.dart';

class CloudSearchPage extends StatelessWidget {
  final AppBloc appBloc;
  final void Function(AppUIEvent action) onPerformAction;

  const CloudSearchPage(
      {super.key, required this.appBloc, required this.onPerformAction});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
        bloc: appBloc, // provide the local bloc instance
        builder: (context, state) {
          return _CloudSearchPageContent(
              settings: state.settings,
              cloudState: state.cloudState,
              onPerformAction: onPerformAction);
        });
  }
}

class _CloudSearchPageContent extends StatefulWidget {
  final AppSettings settings;
  final CloudState cloudState;
  final void Function(AppUIEvent action) onPerformAction;

  const _CloudSearchPageContent(
      {required this.settings,
      required this.cloudState,
      required this.onPerformAction});

  @override
  State<StatefulWidget> createState() => _CloudSearchPageContentState();
}

class _CloudSearchPageContentState extends State<_CloudSearchPageContent> {
  static double _titleHeight = 110.0;
  static const _dividerHeight = 1.0;
  static double get _itemHeight => _titleHeight + _dividerHeight;

  final _cloudSearchTextFieldController = TextEditingController();

  OrderBy _orderBy = OrderBy.byIdDesc;

  @override
  void initState() {
    super.initState();
    _restoreSearchState(widget.cloudState);
  }

  @override
  Widget build(BuildContext context) {
    _titleHeight = widget.settings.textStyler.fontSizeCommon * 3 + 50;
    return Scaffold(
      backgroundColor: widget.settings.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(SongRepository.artistCloudSearch,
            style: widget.settings.textStyler.textStyleFixedBlackBold),
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            widget.onPerformAction(Back());
          },
        ),
      ),
      body: Center(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = constraints.maxWidth;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _CloudSearchPanel(
                  settings: widget.settings,
                  maxWidth: maxWidth,
                  orderBy: _orderBy,
                  cloudSearchTextFieldController:
                      _cloudSearchTextFieldController,
                  onSelectOrderBy: (newOrderBy) {
                    setState(() {
                      _orderBy = newOrderBy;
                    });
                  },
                  onPerformCloudSearch: _performCloudSearch),
              _content(widget.settings, widget.cloudState),
            ],
          );
        }),
      ),
    );
  }

  Widget _content(AppSettings settings, CloudState cloudState) {
    if (cloudState.currentSearchState == SearchState.loading) {
      cloudState.currentSearchPager?.getPage(0, false);
      return _ProgressIndicator(theme: settings.theme);
    } else if (cloudState.currentSearchState == SearchState.empty) {
      return _EmptyListIndicator(settings: settings);
    } else if (cloudState.currentSearchState == SearchState.error) {
      return _ErrorIndicator(settings: settings);
    } else {
      return Flexible(
          child: _CloudTitleListView(
              settings: settings,
              cloudState: cloudState,
              itemHeight: _itemHeight,
              dividerHeight: _dividerHeight,
              onPerformAction: widget.onPerformAction,
              onBackupSearchState: _backupSearchState));
    }
  }

  void _performCloudSearch() {
    _backupSearchState();
    final searchFor = _cloudSearchTextFieldController.text;
    widget.onPerformAction(CloudSearch(searchFor, _orderBy));
  }

  void _backupSearchState() {
    final searchFor = _cloudSearchTextFieldController.text;
    widget.onPerformAction(BackupSearchState(searchFor, _orderBy));
  }

  void _restoreSearchState(CloudState cloudState) {
    _cloudSearchTextFieldController.text = cloudState.searchForBackup;
    setState(() {
      _orderBy = cloudState.orderByBackup;
    });
  }
}

class _ProgressIndicator extends StatelessWidget {
  final AppTheme theme;

  const _ProgressIndicator({required this.theme});

  @override
  Widget build(BuildContext context) => Expanded(
          child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            color: theme.colorMain,
          ),
        ),
      ));
}

class _EmptyListIndicator extends StatelessWidget {
  final AppSettings settings;

  const _EmptyListIndicator({required this.settings});

  @override
  Widget build(BuildContext context) => Expanded(
          child: Center(
              child: Text(
        AppStrings.strListIsEmpty,
        style: settings.textStyler.textStyleTitle,
      )));
}

class _ErrorIndicator extends StatelessWidget {
  final AppSettings settings;

  const _ErrorIndicator({required this.settings});

  @override
  Widget build(BuildContext context) => Expanded(
          child: Center(
              child: Text(
        AppStrings.strErrorFetchData,
        style: settings.textStyler.textStyleTitle,
      )));
}

class _CloudSearchPanel extends StatelessWidget {
  final AppSettings settings;
  final double maxWidth;
  final OrderBy orderBy;
  final TextEditingController cloudSearchTextFieldController;
  final void Function(OrderBy newOrderBy) onSelectOrderBy;
  final void Function() onPerformCloudSearch;

  const _CloudSearchPanel(
      {required this.settings,
      required this.maxWidth,
      required this.orderBy,
      required this.cloudSearchTextFieldController,
      required this.onSelectOrderBy,
      required this.onPerformCloudSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: Column(children: [
              SizedBox(
                width: maxWidth - 100,
                height: 48,
                child: TextField(
                  key: const Key(TestKeys.cloudSearchTextField),
                  controller: cloudSearchTextFieldController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                        vertical:
                            (32 - settings.textStyler.fontSizeCommon) / 2),
                    fillColor: settings.theme.colorMain,
                    filled: true,
                  ),
                  style: settings.textStyler.textStyleCommonInverted,
                ),
              ),
              Container(
                width: maxWidth - 100,
                height: 40,
                color: settings.theme.colorCommon,
                child: DropdownButton(
                  items: orderByDropdownItems(settings),
                  hint: SizedBox(
                    width: maxWidth - 100,
                    child: Text(
                      orderBy.orderByRus,
                      style: settings.textStyler.textStyleCommonBlack,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  isExpanded: true,
                  onChanged: (String? value) {
                    final orderByStr = value ?? OrderBy.byIdDesc.orderByStr;
                    final newOrderBy =
                        OrderByStrings.parseFromString(orderByStr);
                    if (newOrderBy != orderBy) {
                      onSelectOrderBy(newOrderBy);
                      onPerformCloudSearch();
                    }
                  },
                  dropdownColor: settings.theme.colorBg,
                  iconSize: 0,
                  underline: const SizedBox(),
                ),
              ),
            ]),
          ),
          const SizedBox(
            width: 4,
          ),
          Container(
            width: 88,
            height: 88,
            color: AppTheme.colorDarkYellow,
            child: IconButton(
              key: const Key(TestKeys.cloudSearchButton),
              icon: Image.asset(AppIcons.icCloudSearch),
              padding: const EdgeInsets.all(8),
              onPressed: () {
                onPerformCloudSearch();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> orderByDropdownItems(AppSettings settings) {
    List<DropdownMenuItem<String>> menuItems = OrderBy.values
        .map((orderBy) => DropdownMenuItem(
            value: orderBy.orderByStr,
            child: Text(
              orderBy.orderByRus,
              style: settings.textStyler.textStyleCommon,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )))
        .toList();

    return menuItems;
  }
}

class _CloudTitleListView extends StatelessWidget {
  final AppSettings settings;
  final CloudState cloudState;
  final double itemHeight;
  final double dividerHeight;
  final void Function(AppUIEvent action) onPerformAction;
  final void Function() onBackupSearchState;

  _CloudTitleListView(
      {required this.settings,
      required this.cloudState,
      required this.itemHeight,
      required this.dividerHeight,
      required this.onPerformAction,
      required this.onBackupSearchState});

  final _cloudTitleScrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  void _scrollToActual(CloudState cloudState) {
    _cloudTitleScrollController.animateTo(
        cloudState.cloudScrollPosition * itemHeight,
        duration: const Duration(milliseconds: 1),
        curve: Curves.ease);
    onPerformAction(UpdateCloudSongListNeedScroll(false));
  }

  @override
  Widget build(BuildContext context) {
    if (cloudState.needScroll) {
      WidgetsBinding.instance
          .scheduleFrameCallback((_) => _scrollToActual(cloudState));
    }
    return CustomScrollView(
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
                  titleViews =
                      Iterable<int>.generate(snapshot.data?.length ?? 0)
                          .map((listIndex) {
                    final cloudSong = snapshot.data!.elementAt(listIndex);
                    final cloudSongIndex = pageIndex * pageSize + listIndex;
                    return _TitleItem(
                        settings: settings,
                        cloudState: cloudState,
                        cloudSong: cloudSong,
                        cloudSongIndex: cloudSongIndex,
                        itemHeight: itemHeight,
                        dividerHeight: dividerHeight,
                        onItemTap: (cloudSongIndex) {
                          onBackupSearchState();
                          onPerformAction(CloudSongClick(cloudSongIndex));
                        });
                  }).toList();
                  return SizedBox(
                    height: itemHeight * titleViews.length,
                    child: Column(
                      children: titleViews,
                    ),
                  );
                } else {
                  titleViews =
                      Iterable<int>.generate(pageSize).map((listIndex) {
                    final cloudSongIndex = pageIndex * pageSize + listIndex;
                    return _TitleItem(
                        settings: settings,
                        cloudState: cloudState,
                        cloudSong: null,
                        cloudSongIndex: cloudSongIndex,
                        itemHeight: itemHeight,
                        dividerHeight: dividerHeight,
                        onItemTap: (cloudSongIndex) {
                          onBackupSearchState();
                          onPerformAction(CloudSongClick(cloudSongIndex));
                        });
                  }).toList();
                }
                return SizedBox(
                  height: itemHeight * titleViews.length,
                  child: Column(
                    children: titleViews,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

class _TitleItem extends StatelessWidget {
  final AppSettings settings;
  final CloudState cloudState;
  final CloudSong? cloudSong;
  final int cloudSongIndex;
  final double itemHeight;
  final double dividerHeight;
  final void Function(int cloudSongIndex) onItemTap;

  const _TitleItem(
      {required this.settings,
      required this.cloudState,
      required this.cloudSong,
      required this.cloudSongIndex,
      required this.itemHeight,
      required this.dividerHeight,
      required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final extraLikes = cloudState.allLikes[cloudSong] ?? 0;
    final extraDislikes = cloudState.allDislikes[cloudSong] ?? 0;

    return GestureDetector(
      onTap: () {
        onItemTap(cloudSongIndex);
      },
      child: Container(
          height: itemHeight,
          color: settings.theme.colorBg,
          child: Column(children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  cloudSong?.visibleTitleWithRating(
                          extraLikes, extraDislikes) ??
                      '',
                  style: settings.textStyler.textStyleCommon,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Spacer(),
            AppDivider(
              height: dividerHeight,
              color: settings.theme.colorMain,
            )
          ])),
    );
  }
}
