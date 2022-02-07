export 'sponsor_block.dart';

/// Class to convert json response from sposor api to object
class SponsorBlock {
  /// The video id
  late final String videoID;

  /// The video's full hash
  late final String hash;

  /// The video's segments
  late final List<Segment> segments;

  SponsorBlock.fromJson(Map<String, dynamic> json) {
    videoID = json['videoID'];
    hash = json['hash'];
    segments = (json['segments'] as List)
        .map((e) => Segment.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// A segment of a video
class Segment {
  /// The segment to skip/mute. Where the first number is the start (in seconds) and the second number is the end (in seconds).
  late final List<num> segment;

  /// The segment's uuid
  late final String uuid;

  /// Whether the segment is locked or not
  late final int locked;

  /// The segment's category
  late final String category;

  /// The segment's action type
  late final String actionType;

  /// The number of votes the segment has
  late final int votes;

  /// The video duration
  late final num videoDuration;

  /// The id of the segment's creator
  late final String userId;

  /// The description of the segment
  late final String description;

  Segment.fromJson(dynamic data) {
    category = data['category'];
    actionType = data['actionType'];
    segment = (data['segment'] as List<dynamic>).cast<num>();
    uuid = data['UUID'];
    locked = data['locked'];
    votes = data['votes'];
    videoDuration = data['videoDuration'];
    userId = data['userID'];
    description = data['description'];
  }
}
