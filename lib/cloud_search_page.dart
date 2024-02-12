import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/app_divider.dart';
import 'package:russian_rock_song_book/app_strings.dart';
import 'package:russian_rock_song_book/order_by.dart';
import 'package:russian_rock_song_book/song_repository.dart';

import 'app_actions.dart';
import 'app_icons.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'cloud_search_pager.dart';

class CloudSearchPage extends StatefulWidget {

  final AppTheme theme;
  final CloudState cloudState;
  final void Function(AppUIAction action) onPerformAction;

  const CloudSearchPage(
      this.theme,
      this.cloudState,
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
  @override
  void initState() {
    super.initState();
    _restoreSearchState();
  }

  void _scrollToActual() {
    _cloudTitleScrollController.animateTo(widget.cloudState.cloudScrollPosition * _itemHeight,
        duration: const Duration(milliseconds: 1), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.cloudState.currentSearchState == SearchState.idle) {
    //   WidgetsBinding.instance.scheduleFrameCallback((_) => _scrollToActual());
    // }
    return Scaffold(
      backgroundColor: widget.theme.colorBg,
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
              _makeCloudSearchPanel(maxWidth),
              _content(),
            ],
          );
        }),
      ),
    );
  }

  Widget _content() {
    if (widget.cloudState.currentSearchState == SearchState.loading) {
      widget.cloudState.currentSearchPager?.getPage(0, false);
      return _makeProgressIndicator();
    } else if (widget.cloudState.currentSearchState == SearchState.empty) {
      return _makeEmptyListIndicator();
    } else {
      return Flexible(child: _makeCloudTitleListView());
    }
  }

  Widget _makeProgressIndicator() => Expanded(
      child: Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            color: widget.theme.colorMain,
          ),
        ),
      )
  );

  Widget _makeEmptyListIndicator() => Expanded(
      child: Center(
        child: Text(
          AppStrings.strListIsEmpty,
          style: TextStyle(
            color: widget.theme.colorMain,
            fontSize: 24,
          ),
        )
      )
  );

  Widget _makeCloudSearchPanel(double maxWidth) {
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
                        fillColor: widget.theme.colorMain,
                        filled: true,
                      ),
                      style: TextStyle(
                        color: widget.theme.colorBg,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: maxWidth - 100,
                      height: 40,
                      child: DropdownButton(
                        value: orderBy.orderByStr,
                        items: orderByDropdownItems,
                        isExpanded: true,
                        onChanged: (String? value) {
                          final orderByStr = value ??
                              OrderBy.byIdDesc.orderByStr;
                          setState(() {
                            orderBy =
                                OrderByStrings.parseFromString(orderByStr);
                          });
                        },
                        dropdownColor: widget.theme.colorBg,
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

  List<DropdownMenuItem<String>> get orderByDropdownItems{
    List<DropdownMenuItem<String>> menuItems = OrderBy.values.map((orderBy) =>
        DropdownMenuItem(value: orderBy.orderByStr, child: Text(orderBy.orderByRus, style: TextStyle(color: widget.theme.colorMain)))
    ).toList();

    return menuItems;
  }

  Widget _makeCloudTitleListView() => CustomScrollView(
    controller: _cloudTitleScrollController,
    slivers: [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          childCount: widget.cloudState.lastPage?.plus(1), (context, pageIndex) {
            return FutureBuilder(
              future: widget.cloudState.currentSearchPager?.getPage(pageIndex, false),
              initialData: null,
              builder: (context, snapshot) {
                final titleViews = Iterable<int>.generate(
                    snapshot.data?.length ?? 0).map((listIndex) {
                  final cloudSong = snapshot.data!.elementAt(listIndex);
                  final cloudSongIndex = pageIndex * pageSize + listIndex;
                  return GestureDetector(
                    onTap: () {
                      _backupSearchState();
                      widget.onPerformAction(CloudSongClick(cloudSongIndex));
                    },
                    child: Container(
                        height: _itemHeight,
                        color: widget.theme.colorBg,
                        child: Column(
                            children: [
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      cloudSong.artist,
                                      style: TextStyle(
                                          color: widget.theme.colorMain)),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                      cloudSong.visibleTitleWithRating,
                                      style: TextStyle(
                                          color: widget.theme.colorMain)),
                                ),
                              ),
                              const Spacer(),
                              AppDivider(
                                height: _dividerHeight,
                                color: widget.theme.colorMain,
                              )
                            ]
                        )
                    ),
                  );
                }).toList();
                if (snapshot.data != null) {
                  return SizedBox(
                    height: _itemHeight * titleViews.length,
                    child: Column(
                      children: titleViews,
                    ),
                  );
                } else {
                  return const SizedBox(
                    height: _itemHeight * pageSize / 3,
                  );
                }
              },
            );
          }
        ),
      ),
    ],
  );

  void _performCloudSearch() {
    _backupSearchState();
    final searchFor = _cloudSearchTextFieldController.text;
    widget.onPerformAction(CloudSearch(searchFor, orderBy));
  }

  void _backupSearchState() {
    final searchFor = _cloudSearchTextFieldController.text;
    widget.onPerformAction(BackupSearchState(searchFor, orderBy));
  }

  void _restoreSearchState() {
    _cloudSearchTextFieldController.text = widget.cloudState.searchForBackup;
    setState(() {
      orderBy = widget.cloudState.orderByBackup;
    });
  }
}
