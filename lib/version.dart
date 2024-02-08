
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class Version {

  static const versionKey = 'version';
  static const actualVersion = 11;

  static Future<bool> appWasUpdated() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(versionKey) ?? 0;
    log("versions: $savedVersion / $actualVersion");
    return actualVersion > savedVersion;
  }

  static Future<void> confirmAppUpdate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(versionKey, actualVersion);
  }
}