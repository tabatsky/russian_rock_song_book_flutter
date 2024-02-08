import 'package:flutter/material.dart';

typedef WarningSender = void Function(String comment);

class WarningDialog {
  static Future<void> showWarningDialog(BuildContext context, WarningSender warningSender) {
    final commentEditorController = TextEditingController();
    const editorHeight = 200.0;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send warning'),
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.zero,
                ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Send'),
              onPressed: () {
                final comment = commentEditorController.text;
                _sendWarning(warningSender, comment);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
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