export 'write_tags.dart';

import 'dart:io';
import 'package:dart_tags/dart_tags.dart';

Future<List<int>> writeTags(Tag tag, String filePath) {
  final file = File(filePath);
  // try {
  return TagProcessor().putTagsToByteArray(file.readAsBytes(), [tag]);
  // } catch (e) {
  //   print((e as dynamic).stackTrace);
  // }
}
