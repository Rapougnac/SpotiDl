export 'on_submitted.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:dart_tags/dart_tags.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:spotidl/util/get_music_directory.dart';
import 'package:spotidl/util/safe_file_name.dart';
import 'package:spotidl/util/to_stream.dart';
import 'package:spotidl/util/write_tags.dart';
import 'create_hidden_folder_win.dart';
import 'get_infos.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:spotify/spotify.dart';
import 'package:spotidl/errors/not_found.dart';

onSubmitted(String song, BuildContext context) async {
  final musicDir = getMusicDirectory();
  if (song.isEmpty) return;

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
              child: const Text('Settings'),
              onPressed: () async {
                final res = await openAppSettings();
                if (res) {
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to open settings'),
                    ),
                  );
                  return;
                }
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
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
              child: const Text('Settings'),
              onPressed: () async {
                final res = await openAppSettings();
                if (res) {
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to open settings'),
                    ),
                  );
                  return;
                }
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  } else {
    permissionGranted = true;
  }

  if (permissionGranted) {
    final mainDir = Directory('${musicDir.path}${path.separator}SpotifyDl');
    if (!mainDir.existsSync()) {
      await mainDir.create(recursive: true);
    }

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
    } on UnsupportedError {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsupported Song'),
          content: const Text(
              'The song you are looking for is not supported, if it\'s a playlist or album, this is currently not supported'),
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
    final directory = getMusicDirectory();
    final tempDir = Platform.isWindows
        ? await createHiddenFolder(
            '${directory.path}${path.separator}SpotiDL${path.separator}.tmp')
        : await Directory(
                '${directory.path}${path.separator}SpotiDL${path.separator}.tmp')
            .create(recursive: true);
    if (infos is Track) {
      final response =
          await http.get(Uri.parse(infos.album!.images!.first.url!));

      final _file = File(
          '${tempDir.path}${path.separator}${safeFileName(infos.name!)}.jpg');
      if (!_file.existsSync()) {
        try {
          await _file.create();
        } on FileSystemException {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'There was an error creating the album cover, please try again, or check your storage permission.\nMake sure to allow writing permission'),
              actions: [
                TextButton(
                  child: const Text('Settings'),
                  onPressed: () async {
                    await openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          );
          return;
        }
      }
      await _file.writeAsBytes(response.bodyBytes);
      final file = File(
          '${musicDir.path}${path.separator}SpotifyDL${path.separator}${safeFileName(infos.name!)}.mp3');
      if (!file.existsSync()) {
        try {
          file.createSync();
        } on FileSystemException {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: const Text(
                  'There was an error creating the file, please try again, or check your storage permission.\nMake sure to allow writing permission, or, have-you enough free space?'),
              actions: [
                TextButton(
                  child: const Text('Settings'),
                  onPressed: () async {
                    await openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          );
          return;
        }
      }
      final fileStream = file.openWrite();
      await stream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();
      final pic = AttachedPicture('image/jpeg', 0x03, path.basename(_file.path),
          _file.readAsBytesSync());
      Tag tags = Tag();
      try {
        tags = Tag()
          ..tags = {
            'title': infos.name,
            'artist': infos.artists?.map((e) => e.name).join('; '),
            'album': infos.album?.name,
            'track': infos.trackNumber,
            'disc': infos.discNumber,
            'picture': {pic.key: pic},
          }
          ..type = 'ID3'
          ..version = '2.4';
      } catch (e) {
        print(e);
      }

      writeTags(tags, file.path);

      return file;
    }
  }
}
