import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'app_actions.dart';
import 'app_icons.dart';
import 'app_state.dart';
import 'app_strings.dart';
import 'app_theme.dart';

class SettingsPage extends StatefulWidget {
  final ValueStream<AppState> appStateStream;
  final void Function(AppUIAction action) onPerformAction;

  const SettingsPage(this.appStateStream, this.onPerformAction, {super.key});

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsPage> {

  AppTheme _theTheme = AppTheme.themeDark;

  bool _loadDone = false;

  void _loadStateFromSettings(AppSettings settings) {
    setState(() {
      _theTheme = settings.theme;
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
        title: const Text(AppStrings.strSettings),
        leading: IconButton(
          icon: Image.asset(AppIcons.icBack),
          iconSize: 50,
          onPressed: () {
            widget.onPerformAction(Back());
          },
        ),
      ),
      body: Container(
        child: _makeSettingsView(context, settings),
      ),
    );
  }

  Widget _makeSettingsView(BuildContext context, AppSettings settings) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 200,
              height: 80,
              child: DropdownButton(
                value: _theTheme.description,
                items: themeDropdownItems(settings.theme),
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
          ],
        ),
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
                      style: TextStyle(color: settings.theme.colorMain, fontSize: 24)),
                ),
              ),
            ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> themeDropdownItems(AppTheme appTheme) {
    List<DropdownMenuItem<String>> menuItems = AppTheme.allThemes.map((theTheme) =>
        DropdownMenuItem(value: theTheme.description,
            child: Text(theTheme.description, style: TextStyle(color: appTheme.colorMain)))
    ).toList();

    return menuItems;
  }

  void _saveSettings(AppSettings settings) {
    final newSettings = settings;
    newSettings.theme = _theTheme;
    widget.onPerformAction(SaveSettings(newSettings));
  }
}