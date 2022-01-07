export 'on_submitted.dart';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:spotidl/util/get_music_directory.dart';
import 'package:spotidl/util/safe_file_name.dart';
import 'package:spotidl/util/to_stream.dart';
import 'get_infos.dart';
import 'is_first_time.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:spotify/spotify.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotidl/errors/not_found.dart';

onSubmitted(String song, BuildContext context) async {
  final musicDir = getMusicDirectory();
  Directory directory = Directory('${musicDir.path}${path.separator}SpotifyDl');
  await isFirstTime()
      ? (await Directory('${musicDir.path}${path.separator}SpotifyDl')
          .create(recursive: false))
      : null;
  if (song.isEmpty) return;

  Directory? dir;

  if (Platform.isAndroid) {
    dir = await getExternalStorageDirectory();
  } else {
    dir = await getApplicationDocumentsDirectory();
  }
  bool permissionGranted = false;
  if (Platform.isAndroid) {
    if (await Permission.storage.request().isGranted) {
      permissionGranted = true;
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Storage Permission Permanently Denied'),
          content: const Text('Please enable storage permission in settings'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    } else if (await Permission.storage.request().isDenied) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Storage Permission Denied'),
          content: const Text('Please enable storage permission in settings'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
    }
  } else {
    permissionGranted = true;
  }

  if (permissionGranted) {
    // TODO: Add a loading indicator
    // CircularProgressIndicator();
    Stream<List<int>> stream;
    try {
      stream = await toStream(song);
    } on NotFound {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Song Not Found'),
          content: const Text(
              'The song you are looking for is not found, please try again'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        ),
      );
      return;
    }
    final infos = await getInfos(song);
    if (infos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Song not found'),
        ),
      );
      return;
    }
    final tempDir =
        await Directory('${directory.path}${path.separator}.tmp').create();
    if (infos is Track) {
      final response =
          await http.get(Uri.parse(infos.album!.images!.first.url!));

      final _file = File('${tempDir.path}${path.separator}album.jpg');
      await _file.writeAsBytes(response.bodyBytes);
      // await Directory(safeFileName(tr));
      final file = File(
          '${directory.path}${path.separator}${safeFileName(infos.name!)}');
      final fileStream = file.openWrite();
      await stream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();
    }
  }
}
