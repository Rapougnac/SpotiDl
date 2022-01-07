export 'is_first_time.dart';

import 'package:shared_preferences/shared_preferences.dart';

Future<bool> isFirstTime() async {
  var prefs = await SharedPreferences.getInstance();
  bool _seen = (prefs.getBool('seen') ?? false);

  if (_seen) {
    return false;
  } else {
    await prefs.setBool('seen', true);
    return true;
  }
}