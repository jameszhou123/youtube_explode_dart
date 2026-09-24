import 'dart:convert';

import 'package:test/test.dart';
// ignore: implementation_imports
import 'package:youtube_explode_dart/src/reverse_engineering/pages/channel_upload_page.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Offline: a channel Videos tab where one item is malformed. Before
/// 2026-09-24 the parse had no per-item guard, so a single odd item (here, a
/// lockup with no videoId) threw and emptied the whole list.
void main() {
  Map<String, dynamic> lockup({String? videoId, required String title}) => {
        'richItemRenderer': {
          'content': {
            'lockupViewModel': {
              'contentType': 'LOCKUP_CONTENT_TYPE_VIDEO',
              'metadata': {
                'lockupMetadataViewModel': {
                  'title': {'content': title},
                  'metadata': {
                    'contentMetadataViewModel': {
                      'metadataRows': [
                        {
                          'metadataParts': [
                            {
                              'text': {'content': '1K views'}
                            },
                            {
                              'text': {'content': '2 days ago'},
                              'accessibilityLabel': '2 days ago',
                            },
                          ],
                        },
                      ],
                    },
                  },
                },
              },
              'contentImage': {
                'thumbnailViewModel': {
                  'image': {
                    'sources': [
                      {'url': 'https://i.ytimg.com/x.jpg'}
                    ],
                  },
                  'overlays': [
                    {
                      'thumbnailBottomOverlayViewModel': {
                        'badges': [
                          {
                            'thumbnailBadgeViewModel': {'text': '10:00'}
                          },
                        ],
                      },
                    },
                  ],
                },
              },
              if (videoId != null)
                'rendererContext': {
                  'commandContext': {
                    'onTap': {
                      'innertubeCommand': {
                        'watchEndpoint': {'videoId': videoId}
                      },
                    },
                  },
                },
            },
          },
        },
      };

  String page(List<Map<String, dynamic>> items) {
    final data = {
      'contents': {
        'twoColumnBrowseResultsRenderer': {
          'tabs': [
            {
              'tabRenderer': {
                'selected': true,
                'endpoint': {
                  'commandMetadata': {
                    'webCommandMetadata': {'url': '/@someone/videos'}
                  },
                },
                'content': {
                  'richGridRenderer': {'contents': items},
                },
              },
            },
          ],
        },
      },
    };
    return '<html><body><script>var ytInitialData = '
        '${jsonEncode(data)};</script></body></html>';
  }

  test('a malformed item is skipped, the rest of the page still parses', () {
    final parsed = ChannelUploadPage.parse(
      page([
        lockup(title: 'No id'),
        lockup(videoId: 'dQw4w9WgXcQ', title: 'Good'),
      ]),
      'UCxxxxxxxxxxxxxxxxxxxxxx',
      VideoType.normal,
    );
    final uploads = parsed.uploads;
    expect(uploads, hasLength(1));
    expect(uploads.single.videoId.value, 'dQw4w9WgXcQ');
    expect(uploads.single.videoTitle, 'Good');
    expect(uploads.single.videoDuration, const Duration(minutes: 10));
  });
}
