import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/mvi/actions/app_actions.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/ui/font/app_font.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:rxdart/rxdart.dart';

class SettingsPage extends StatefulWidget {
  final ValueStream<AppState> appStateStream;
  final void Function(AppUIAction action) onPerformAction;

  const SettingsPage(this.appStateStream, this.onPerformAction, {super.key});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {

  AppTheme _theTheme = AppTheme.themeDark;
  ListenToMusicPreference _theListenToMusicPreference = ListenToMusicPreference.yandexAndYoutube;
  FontScaleVariant _theFontScaleVariant = FontScaleVariant.m;

  bool _loadDone = false;

  void _loadStateFromSettings(AppSettings settings) {
    setState(() {
      _theTheme = settings.theme;
      _theListenToMusicPreference = settings.listenToMusicPreference;
      _theFontScaleVariant = settings.fontScaleVariant;
      _loadDone = true;
    });
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
          if (!_loadDone) {
            WidgetsBinding.instance.scheduleFrameCallback((_) =>
                _loadStateFromSettings(appState.settings));
          }
          return _makePage(context, appState.settings);
        }
    );
  }

  Widget _makePage(BuildContext context, AppSettings settings) {
    return Scaffold(
      backgroundColor: settings.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(AppStrings.strSettings, style: settings.textStyler.textStyleFixedBlackBold),
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            widget.onPerformAction(Back());
          },
        ),
      ),
      body: Container(
        child:  LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = constraints.maxWidth;
          return _makeSettingsView(maxWidth, settings);
        }),
      ),
    );
  }

  Widget _makeSettingsView(double width, AppSettings settings) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _makeThemeRow(width, settings),
        _makeListenToMusicRow(width, settings),
        _makeFontScaleRow(width, settings),
        const Spacer(),
        TextButton(
            onPressed: () { _saveSettings(settings); },
            child: Container(
              color: settings.theme.colorCommon,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(AppStrings.strSave,
                      style: settings.textStyler.textStyleTitle),
                ),
              ),
            ),
        ),
      ],
    );
  }

  Widget _makeThemeRow(double width, AppSettings settings) => Row(
    children: [
      SizedBox(
        width: width / 2,
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(AppStrings.strTheme,
              style: settings.textStyler.textStyleCommon,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      SizedBox(
        width: width / 2,
        height: 60,
        child: Align(
          alignment: Alignment.centerLeft,
          child: DropdownButton(
            value: _theTheme.description,
            items: _themeDropdownItems(settings),
            isExpanded: true,
            onChanged: (String? value) {
              final description = value ??
                  _theTheme.description;
              final newIndex = AppTheme.indexFromDescription(description);
              final newTheme = AppTheme.allThemes[newIndex];
              setState(() {
                _theTheme = newTheme;
              });
            },
            dropdownColor: settings.theme.colorBg,
          ),
        ),
      ),
    ],
  );

  Widget _makeListenToMusicRow(double width, AppSettings settings) => Row(
    children: [
      SizedBox(
        width: width / 2,
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(AppStrings.strListenToMusic,
              style: settings.textStyler.textStyleCommon,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      SizedBox(
        width: width / 2,
        height: 60,
        child: Align(
          alignment: Alignment.centerLeft,
          child: DropdownButton(
            value: _theListenToMusicPreference.description,
            items: _listenToMusicDropdownItems(settings),
            isExpanded: true,
            onChanged: (String? value) {
              final description = value ??
                  _theListenToMusicPreference.description;
              final newIndex = ListenToMusicPreference.indexFromDescription(description);
              final newPreference = ListenToMusicPreference.allVariants[newIndex];
              setState(() {
                _theListenToMusicPreference = newPreference;
              });
            },
            dropdownColor: settings.theme.colorBg,
          ),
        ),
      ),
    ],
  );

  Widget _makeFontScaleRow(double width, AppSettings settings) => Row(
    children: [
      SizedBox(
        width: width / 2,
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(AppStrings.strFontScale,
              style: settings.textStyler.textStyleCommon,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      SizedBox(
        width: width / 2,
        height: 60,
        child: Align(
          alignment: Alignment.centerLeft,
          child: DropdownButton(
            value: _theFontScaleVariant.description,
            items: _fontScaleDropdownItems(settings),
            isExpanded: true,
            onChanged: (String? value) {
              final description = value ??
                  _theFontScaleVariant.description;
              final newIndex = FontScaleVariant.indexFromDescription(description);
              final newVariant = FontScaleVariant.allVariants[newIndex];
              setState(() {
                _theFontScaleVariant = newVariant;
              });
            },
            dropdownColor: settings.theme.colorBg,
          ),
        ),
      ),
    ],
  );

  List<DropdownMenuItem<String>> _themeDropdownItems(AppSettings settings) {
    List<DropdownMenuItem<String>> menuItems = AppTheme.allThemes.map((theTheme) =>
        DropdownMenuItem(value: theTheme.description,
            child: Text(
              theTheme.description,
              style: settings.textStyler.textStyleCommon,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ))
    ).toList();

    return menuItems;
  }

  List<DropdownMenuItem<String>> _listenToMusicDropdownItems(AppSettings settings) {
    List<DropdownMenuItem<String>> menuItems = ListenToMusicPreference.allVariants.map((thePreference) =>
        DropdownMenuItem(value: thePreference.description,
            child: Text(
              thePreference.description,
              style: settings.textStyler.textStyleCommon,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ))
    ).toList();

    return menuItems;
  }

  List<DropdownMenuItem<String>> _fontScaleDropdownItems(AppSettings settings) {
    List<DropdownMenuItem<String>> menuItems = FontScaleVariant.allVariants.map((theVariant) =>
        DropdownMenuItem(value: theVariant.description,
            child: Text(
              theVariant.description,
              style: settings.textStyler.textStyleCommon,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ))
    ).toList();

    return menuItems;
  }

  void _saveSettings(AppSettings settings) {
    final newSettings = settings;
    newSettings.theme = _theTheme;
    newSettings.listenToMusicPreference = _theListenToMusicPreference;
    newSettings.fontScaleVariant = _theFontScaleVariant;
    widget.onPerformAction(SaveSettings(newSettings));
  }
}