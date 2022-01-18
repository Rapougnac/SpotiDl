export 'write_tags.dart';

import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:dart_tags/dart_tags.dart';

void writeTags(Tag tag, String filePath) async {
  var file = File(filePath);
  try {
    await TagProcessor().putTagsToByteArray(file.readAsBytes(), [tag]);
  } catch (e) {
    print((e as dynamic).stackTrace);
  }
}
