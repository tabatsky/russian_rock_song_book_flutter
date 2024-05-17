import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/data/settings/font_scale_variant.dart';
import 'package:russian_rock_song_book/mvi/actions/app_events.dart';
import 'package:russian_rock_song_book/mvi/state/app_state.dart';
import 'package:russian_rock_song_book/data/settings/listen_to_music.dart';
import 'package:russian_rock_song_book/ui/icons/app_icons.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';
import 'package:russian_rock_song_book/ui/theme/app_theme.dart';
import 'package:rxdart/rxdart.dart';

class SettingsPage extends StatelessWidget {
  final ValueStream<AppState> appStateStream;
  final void Function(AppUIEvent action) onPerformAction;

  const SettingsPage(this.appStateStream, this.onPerformAction, {super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppState>(
        stream: appStateStream,
        builder: (BuildContext context, AsyncSnapshot<AppState> snapshot) {
          final appState = snapshot.data;
          if (appState == null) {
            return Container();
          }
          return _SettingsPageContent(appState.settings, appState, onPerformAction);
        }
    );
  }
}

class _SettingsPageContent extends StatelessWidget {
  final AppSettings settings;
  final AppState appState;
  final void Function(AppUIEvent action) onPerformAction;

  const _SettingsPageContent(this.settings, this.appState, this.onPerformAction);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: settings.theme.colorBg,
      appBar: AppBar(
        backgroundColor: AppTheme.colorDarkYellow,
        title: Text(AppStrings.strSettings, style: settings.textStyler.textStyleFixedBlackBold),
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            onPerformAction(Back());
          },
        ),
      ),
      body: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        double maxWidth = constraints.maxWidth;
        return _SettingsBody(settings, appState, maxWidth, onPerformAction);
      }),
    );
  }

}

class _SettingsBody extends StatefulWidget {
  final AppSettings settings;
  final AppState appState;
  final double width;
  final void Function(AppUIEvent action) onPerformAction;

  const _SettingsBody(this.settings, this.appState, this.width, this.onPerformAction);

  @override
  State<StatefulWidget> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<_SettingsBody> {
  AppTheme _theTheme = AppTheme.themeDark;
  ListenToMusicVariant _theListenToMusicVariant = ListenToMusicVariant.yandexAndYoutube;
  FontScaleVariant _theFontScaleVariant = FontScaleVariant.m;

  bool _loadDone = false;

  @override
  Widget build(BuildContext context) {
    if (!_loadDone) {
      WidgetsBinding.instance.scheduleFrameCallback((_) =>
          _loadStateFromSettings(widget.appState.settings));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ThemeRow(widget.settings, widget.width, _theTheme, (newVariant) {
          setState(() {
            _theTheme = newVariant;
          });
        }),
        _ListenToMusicRow(widget.settings, widget.width, _theListenToMusicVariant, (newVariant) {
          setState(() {
            _theListenToMusicVariant = newVariant;
          });
        }),
        _FontScaleRow(widget.settings, widget.width, _theFontScaleVariant, (newVariant) {
          setState(() {
            _theFontScaleVariant = newVariant;
          });
        }),
        const Spacer(),
        TextButton(
          onPressed: () { _saveSettings(widget.settings); },
          child: Container(
            color: widget.settings.theme.colorCommon,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(AppStrings.strSave,
                    style: widget.settings.textStyler.textStyleTitle),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _loadStateFromSettings(AppSettings settings) {
    setState(() {
      _theTheme = settings.theme;
      _theListenToMusicVariant = settings.listenToMusicPreference;
      _theFontScaleVariant = settings.fontScaleVariant;
      _loadDone = true;
    });
  }

  void _saveSettings(AppSettings settings) {
    final newSettings = settings;
    newSettings.theme = _theTheme;
    newSettings.listenToMusicPreference = _theListenToMusicVariant;
    newSettings.fontScaleVariant = _theFontScaleVariant;
    widget.onPerformAction(SaveSettings(newSettings));
  }
}

class _ThemeRow extends StatelessWidget {
  final AppSettings settings;
  final double width;
  final AppTheme theTheme;
  final void Function(AppTheme newVariant) setNewVariant;

  const _ThemeRow(this.settings, this.width,
      this.theTheme,
      this.setNewVariant);

  @override
  Widget build(BuildContext context) => Row(
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
            value: theTheme.description,
            items: _themeDropdownItems(settings),
            isExpanded: true,
            onChanged: (String? value) {
              final description = value ??
                  theTheme.description;
              final newIndex = AppTheme.indexFromDescription(description);
              final newTheme = AppTheme.allThemes[newIndex];
              setNewVariant(newTheme);
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
}

class _ListenToMusicRow extends StatelessWidget {
  final AppSettings settings;
  final double width;
  final ListenToMusicVariant theListenToMusicVariant;
  final void Function(ListenToMusicVariant newVariant) setNewVariant;

  const _ListenToMusicRow(this.settings, this.width, this.theListenToMusicVariant,
      this.setNewVariant);

  @override
  Widget build(BuildContext context) => Row(
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
            value: theListenToMusicVariant.description,
            items: _listenToMusicDropdownItems(settings),
            isExpanded: true,
            onChanged: (String? value) {
              final description = value ??
                  theListenToMusicVariant.description;
              final newIndex = ListenToMusicVariant.indexFromDescription(description);
              final newVariant = ListenToMusicVariant.allVariants[newIndex];
              setNewVariant(newVariant);
            },
            dropdownColor: settings.theme.colorBg,
          ),
        ),
      ),
    ],
  );

  List<DropdownMenuItem<String>> _listenToMusicDropdownItems(AppSettings settings) {
    List<DropdownMenuItem<String>> menuItems = ListenToMusicVariant.allVariants.map((theVariant) =>
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
}

class _FontScaleRow extends StatelessWidget {
  final AppSettings settings;
  final double width;
  final FontScaleVariant theFontScaleVariant;
  final void Function(FontScaleVariant newVariant) setNewVariant;

  const _FontScaleRow(this.settings, this.width, this.theFontScaleVariant, this.setNewVariant);

  @override
  Widget build(BuildContext context) => Row(
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
            value: theFontScaleVariant.description,
            items: _fontScaleDropdownItems(settings),
            isExpanded: true,
            onChanged: (String? value) {
              final description = value ??
                  theFontScaleVariant.description;
              final newIndex = FontScaleVariant.indexFromDescription(description);
              final newVariant = FontScaleVariant.allVariants[newIndex];
              setNewVariant(newVariant);
            },
            dropdownColor: settings.theme.colorBg,
          ),
        ),
      ),
    ],
  );

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
}