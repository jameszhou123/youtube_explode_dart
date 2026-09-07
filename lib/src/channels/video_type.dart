import 'package:meta/meta.dart';

/// Video types provided by Youtube
enum VideoType {
  /// Default horizontal video
  normal('videos', 'videoRenderer'),

  /// Youtube shorts video
  shorts('shorts', 'shortsLockupViewModel'),

  /// Live streams tab: ongoing live streams first, then ended streams.
  /// Upcoming (scheduled) streams are skipped since they are not playable yet.
  streams('streams', 'videoRenderer');

  final String name;

  @internal
  final String youtubeRenderText;

  const VideoType(this.name, this.youtubeRenderText);
}
