export 'stream_infos.dart';

import 'dart:convert';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:http/http.dart' as http;

/// Returns a tuple containing 1st, the url, 2nd the bitrate, 3rd the stream size
Future<List> streamInfos(Uri url) async {
  final h = await http.get(url);
  var html = h.body;
  var details = [];
  var fetched = false;

  // Rewritten from: https://github.com/DevAndromeda/youtube-sr/blob/rewrite/src/Util.ts#L108
  try {
    var data = html
        .split('ytInitialData = JSON.parse(\'')[1]
        .split('\');</script>')
        .first;
    html = data.replaceAllMapped(
        RegExp(r'\\x([0-9A-F]{2})', caseSensitive: false),
        (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)));
    // ignore: empty_catches
  } catch (e) {}
  try {
    details = jsonDecode(html
        .split('{"itemSelectionRenderer":{"contents":')
        .last
        .split(',"continuations":[{')
        .first);
    fetched = true;
    // ignore: empty_catches
  } catch (e) {}
  if (!fetched) {
    try {
      details = jsonDecode(html
          .split('{"itemSectionRenderer":')
          .last
          .split('},{"continuationItemRenderer":{')
          .first)['contents'];
      fetched = true;
      // ignore: empty_catches
    } catch (e) {}
  }
  final videoId = details[0]['videoRenderer']['videoId'];
  final yt = YoutubeExplode();
  final manifest = await yt.videos.streamsClient.getManifest(videoId);
  final streamInfo = manifest.audioOnly.withHighestBitrate();

  // Returns tuple of [url, bitrate]
  return [streamInfo.url, streamInfo.bitrate, streamInfo.size];
}
