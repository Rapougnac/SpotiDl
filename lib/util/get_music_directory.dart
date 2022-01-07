export 'get_music_directory.dart';

import 'dart:io';

Directory getMusicDirectory() {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Music');
  } else if (Platform.isWindows) {
    return Directory('${Platform.environment['USERPROFILE']}\\Music');
  } else if (Platform.isLinux || Platform.isMacOS) {
    return Directory('${Platform.environment['HOME']}/Music');
  } else {
    throw UnsupportedError('Platform not supported');
  }
}
