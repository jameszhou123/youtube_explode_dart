import 'package:test/test.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'skip_gh.dart';

void main() {
  YoutubeExplode? yt;
  setUpAll(() {
    yt = YoutubeExplode();
  });

  tearDownAll(() {
    yt?.close();
  });

  test('Get metadata of a channel', () async {
    const channelUrl =
        'https://www.youtube.com/channel/UCEnBXANsKmyj2r9xVyKoDiQ';
    final channel = await yt!.channels.get(ChannelId(channelUrl));
    expect(channel.url, channelUrl);
    expect(channel.title, 'Tyrrrz');
    expect(channel.logoUrl, isNotEmpty);
    expect(channel.logoUrl, isNot(equalsIgnoringWhitespace('')));

    // TODO: Investigate why sometimes the subscriber count is null
    if (channel.subscribersCount != null) {
      expect(channel.subscribersCount, greaterThanOrEqualTo(190));
    }
  });

  group('Get metadata of any channel', () {
    for (final val in {
      'UCqKbtOLx4NCBh5KKMSmbX0g',
      'UCJ6td3C9QlPO9O_J5dF4ZzA',
      'UCiGm_E4ZwYSHV3bcW1pnSeQ',
    }) {
      test('Channel - $val', () async {
        final channelId = ChannelId(val);
        final channel = await yt!.channels.get(channelId);
        expect(channel.id, channelId);
      });
    }
  });

  test('Get metadata of a channel by username', () async {
    final channel = await yt!.channels.getByUsername(Username('TheTyrrr'));
    expect(channel.id.value, 'UCEnBXANsKmyj2r9xVyKoDiQ');
  });

  test('Get metadata of a channel by handle', () async {
    final channel = await yt!.channels.getByHandle(ChannelHandle('@Hexer10'));
    expect(channel.id.value, 'UCqKbtOLx4NCBh5KKMSmbX0g');
  });

  test('Get metadata of a channel by a video', () async {
    final channel = await yt!.channels.getByVideo(VideoId('TW_yxPcodhk'));
    expect(channel.id.value, 'UCqKbtOLx4NCBh5KKMSmbX0g');
  }, skip: skipGH);

  test('Get the videos of a youtube channel', () async {
    final videos = await yt!.channels
        .getUploads(
          ChannelId(
            'https://www.youtube.com/channel/UCqKbtOLx4NCBh5KKMSmbX0g',
          ),
        )
        .toList();
    expect(videos.length, greaterThanOrEqualTo(6));
  });

  group('Get the videos of any youtube channel', () {
    for (final val in {
      'UCqKbtOLx4NCBh5KKMSmbX0g',
      'UCJ6td3C9QlPO9O_J5dF4ZzA',
      'UCiGm_E4ZwYSHV3bcW1pnSeQ',
    }) {
      test('Channel - $val', () async {
        final videos = await yt!.channels.getUploads(ChannelId(val)).toList();
        expect(videos, isNotEmpty);
      });
    }
  });

  test('Get videos of a youtube channel from the uploads page', () async {
    final videos =
        await yt!.channels.getUploadsFromPage('UC6biysICWOJ-C3P4Tyeggzg');
    expect(videos, isNotEmpty);
  });

  test('Get next page youtube channel uploads page', () async {
    final videos =
        await yt!.channels.getUploadsFromPage('UC6biysICWOJ-C3P4Tyeggzg');
    final nextPage = await videos.nextPage();
    expect(nextPage!.length, greaterThanOrEqualTo(20));
  });

  test('Get shorts of a youtube channel from the uploads page', () async {
    final shorts = await yt!.channels.getUploadsFromPage(
        'UCMawD8L365TRdcqhQiTDLKA',
        videoType: VideoType.shorts);
    expect(shorts, isNotEmpty);
  });

  test('getUploadsFromPage populates title + duration (lockupViewModel parse)',
      () async {
    final page =
        await yt!.channels.getUploadsFromPage('UCE6acMV3m35znLcf0JGNn7Q');
    expect(page, isNotEmpty);
    // The lockupViewModel migration left these fields empty while ids still
    // parsed — so a bare `isNotEmpty` check passed even when every title was ''.
    // Assert the fields actually come back, so a future layout shift can't
    // silently re-break the parse.
    final titled = page.where((v) => v.title.trim().isNotEmpty).length;
    final timed =
        page.where((v) => (v.duration ?? Duration.zero) > Duration.zero).length;
    expect(titled, greaterThan(page.length ~/ 2),
        reason: 'most videos should have a parsed title');
    expect(timed, greaterThan(page.length ~/ 2),
        reason: 'most videos should have a parsed duration');
  });
}
