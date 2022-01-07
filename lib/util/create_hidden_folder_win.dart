export 'create_hidden_folder_win.dart';

import 'dart:io';

Future<Directory> createHiddenFolder(String path) async {
  final dir = await Directory(path).create();
  Process.start('attrib', ['+h', dir.path]);
  return dir;
}
