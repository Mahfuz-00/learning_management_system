// Verifies the AppNetworkImage hardening.
//
// Background: `learning.nirvoor.com/uploads/Images/*` currently answers with
// `200 text/html` and the Angular `index.html` body instead of raw image bytes.
// Handing those bytes to Android's decoder produced
// `Exception: Invalid image data` / `ImageDecoder$DecodeException`.
//
// AppNetworkImage now rejects any body that is not a real image before the
// native decoder runs, so the widget shows its fallback instead of crashing.
// These tests cover the byte-signature guard that implements that rejection.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lms_touch_and_solve/Core/Widgets/app_network_image.dart';

void main() {
  group('AppNetworkImage.looksLikeImageBytes', () {
    test('accepts a real PNG', () {
      final png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR42mNk'
        'YAAAAwABlJ3zCQAAAABJRU5ErkJggg==',
      );
      expect(AppNetworkImage.looksLikeImageBytes(png), isTrue);
    });

    test('accepts JPEG, GIF, BMP, WebP and HEIF magic bytes', () {
      expect(
        AppNetworkImage.looksLikeImageBytes(
          Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]),
        ),
        isTrue,
        reason: 'JPEG',
      );
      expect(
        AppNetworkImage.looksLikeImageBytes(
          Uint8List.fromList([0x47, 0x49, 0x46, 0x38, 0x39, 0x61]),
        ),
        isTrue,
        reason: 'GIF',
      );
      expect(
        AppNetworkImage.looksLikeImageBytes(
          Uint8List.fromList([0x42, 0x4D, 0x00, 0x00]),
        ),
        isTrue,
        reason: 'BMP',
      );
      expect(
        AppNetworkImage.looksLikeImageBytes(
          Uint8List.fromList([
            0x52, 0x49, 0x46, 0x46, 0x00, 0x00, 0x00, 0x00, //
            0x57, 0x45, 0x42, 0x50,
          ]),
        ),
        isTrue,
        reason: 'WebP',
      );
      expect(
        AppNetworkImage.looksLikeImageBytes(
          Uint8List.fromList([
            0x00, 0x00, 0x00, 0x20, 0x66, 0x74, 0x79, 0x70, //
            0x68, 0x65, 0x69, 0x63,
          ]),
        ),
        isTrue,
        reason: 'HEIF',
      );
    });

    test('rejects the exact HTML body the server returns', () {
      // First 16 bytes observed from learning.nirvoor.com:
      //   3c 21 64 6f 63 74 79 70 65 20 68 74 6d 6c 3e 0a
      //   "<!doctype html>\n"
      const html = '<!doctype html>\n<html lang="en"><head>'
          '<title>Nirvoor Learning</title></head></html>';
      final bytes = Uint8List.fromList(utf8.encode(html));

      expect(AppNetworkImage.looksLikeImageBytes(bytes), isFalse);
    });

    test('rejects JSON error bodies and empty responses', () {
      expect(
        AppNetworkImage.looksLikeImageBytes(
          Uint8List.fromList(utf8.encode('{"error":"not found"}')),
        ),
        isFalse,
      );
      expect(
        AppNetworkImage.looksLikeImageBytes(Uint8List(0)),
        isFalse,
      );
    });
  });
}
