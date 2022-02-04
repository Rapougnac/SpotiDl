export 'video_renderer.dart';

class VideoRenderer {
  late String videoId;
  late String thumbnail;
  late String title;
  late String artist;
  late String publishedAt;
  late String duration;
  late String viewCount;
  VideoRenderer.fromJson(dynamic data) {
    videoId = data['videoRenderer']['videoId'];
    // thumbnail = data['videoRenderer']['thumbnail']['thumbnails'][0]['url'];
    title = data['videoRenderer']['title']['runs'][0]['text'];
    artist = data['videoRenderer']['longBylineText']['runs'][0]['text'];
    publishedAt = data['videoRenderer']?['publishedTimeText']?['simpleText'] ?? '0';
    duration = data['videoRenderer']['lengthText']['simpleText'];
    viewCount = data['videoRenderer']?['viewCountText']?['simpleText'] ?? '0';
  }

  @override
  String toString() {
    return 'VideoRenderer{videoId: $videoId, thumbnail: $thumbnail, title: $title, artist: $artist, publishedAt: $publishedAt, duration: $duration, viewCount: $viewCount}';
  }
}
