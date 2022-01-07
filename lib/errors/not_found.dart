export 'not_found.dart';

/// A not found exception, thrown when a song is not found, or the user cancels the download
class NotFound extends Error {
  /// The message to display when the error occurs.
  final String message;
  NotFound(this.message);
}