import 'package:test/test.dart';
// ignore: implementation_imports
import 'package:youtube_explode_dart/src/extensions/helpers_extension.dart';

/// `toDateTime` parses a channel item's relative upload date. The channel
/// client maps a whole tab page through it, so it must never throw: in
/// 2026-09 the Streams tab switched to compact dates ("Streamed 10mo ago"),
/// `int.parse('Streamed')` threw, and every stream on the channel was lost.
void main() {
  test('long form still parses', () {
    final date = '2 days ago'.toDateTime();
    expect(date, isNotNull);
    expect(DateTime.now().difference(date!).inDays, 2);
  });

  test('long form with a Streamed prefix still parses', () {
    final date = 'Streamed 3 weeks ago'.toDateTime();
    expect(date, isNotNull);
    expect(DateTime.now().difference(date!).inDays, 21);
  });

  test('compact forms return null instead of throwing', () {
    for (final raw in [
      'Streamed 10mo ago',
      'Streamed 2y ago',
      '10mo ago',
      'Streamed live',
    ]) {
      expect(() => raw.toDateTime(), returnsNormally, reason: raw);
      expect(raw.toDateTime(), isNull, reason: raw);
    }
  });

  test('an unknown unit returns null instead of throwing', () {
    expect('3 fortnights ago'.toDateTime(), isNull);
  });
}
