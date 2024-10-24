import 'package:flutter/material.dart';
import 'package:russian_rock_song_book/mvi/state/app_settings.dart';
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';

typedef WarningSender = void Function(String comment);

class WarningDialog {
  static Future<void> showWarningDialog(BuildContext context, AppSettings settings, WarningSender warningSender) {
    final commentEditorController = TextEditingController();
    const editorHeight = 200.0;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppStrings.strWarningDialogTitle, style: settings.textStyler.textStyleSmallTitle),
          backgroundColor: settings.theme.colorCommon,
          surfaceTintColor: Colors.black,
          content: Container(
            constraints: const BoxConstraints(
              minHeight: editorHeight,
              minWidth: 100,
              maxHeight: editorHeight,
              maxWidth: 100,
            ),
            child: TextField(
                controller: commentEditorController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: settings.textStyler.textStyleCommonInverted,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: settings.theme.colorMain,
                ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppStrings.strSend, style: settings.textStyler.textStyleCommon),
              onPressed: () {
                final comment = commentEditorController.text;
                _sendWarning(warningSender, comment);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppStrings.strCancel, style: settings.textStyler.textStyleCommon),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> _sendWarning(WarningSender warningSender, String comment) async {
    warningSender(comment);
  }
}