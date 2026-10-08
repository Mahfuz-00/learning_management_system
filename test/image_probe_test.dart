// TEMPORARY DIAGNOSTIC PROBE
// ---------------------------------------------------------------------------
// Run with:  flutter test test/image_probe_test.dart --reporter expanded
//
// Purpose: fetch the exact thumbnail URL that Android fails to decode and print
//   1. the HTTP status code
//   2. the `content-type` response header
//   3. a preview of the first bytes of the body
//
// This tells us whether the server really returns raw PNG bytes, or whether it
// is accidentally returning an HTML/JSON error page (which is what makes
// Android's ImageDecoder throw `Invalid image data` / `DecodeException`).
// Delete this file once the issue is confirmed fixed.
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

const String kProbeUrl =
    'https://learning.nirvoor.com/uploads/Images/'
    '6f67c113-5418-4304-a41a-cda20cd8e988_english course thumbnil.png';

// ---------------------------------------------------------------------------
// RESULT (run against the live server on 2026-10-08):
//
//   STATUS CODE   : 200 OK
//   CONTENT-TYPE  : text/html            <-- should be image/png
//   CONTENT-LENGTH: null                 <-- no length, served dynamically
//   SERVER        : cloudflare
//   BODY LENGTH   : 35159 bytes
//   FIRST 16 BYTES: 3c 21 64 6f 63 74 79 70 65 20 68 74 6d 6c 3e 0a
//                   = "<!doctype html>\n"
//   LOOKS LIKE IMAGE (magic bytes)? false
//
// CONCLUSION: This host does not serve uploads. Every /uploads/* request
// (a real image, a fake image, and a fake video all tested) returns 200 with
// the Angular SPA's index.html. The SPA catch-all route swallows /uploads/*.
//
// RESOLVED: The files are served correctly by the API backend instead —
// `https://api.nirvoor.com/uploads/Images/<same-file>` returns
// `200 image/png` with real PNG bytes (verified: 89 50 4E 47, 1536x1024).
// The app's assetBaseUrl was therefore corrected from learning.nirvoor.com to
// api.nirvoor.com, and resolveImageUrl() now rewrites any stored
// learning.nirvoor.com/uploads/* URL onto the API host.
//
// NO SERVER-SIDE CHANGE IS REQUIRED: api.nirvoor.com already serves
// /uploads/Images, /uploads/Videos and /uploads/PDFs with correct 404s for
// missing files (verified), so its static hosting is configured correctly.
// Optional: to avoid the confusing 200 text/html, the learning.nirvoor.com
// Nginx config could return 404 for /uploads/* before the SPA fallback:
//
//   location /uploads/ { return 404; }
//   location / { try_files $uri $uri/ /index.html; }
//

/// Bytes that identify a real image file. A PNG must start with `89 50 4E 47`.
bool _looksLikeImage(Uint8List bytes) {
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return true; // PNG
  }
  if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
    return true; // JPEG
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 &&
      bytes[8] == 0x57 && bytes[9] == 0x45 && bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return true; // WebP
  }
  if (bytes.length >= 4 &&
      bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) {
    return true; // GIF
  }
  return false;
}

void main() {
  test('probe remote image URL and report status/headers/body preview',
      () async {
    // ignore: avoid_print
    print('\n===== AppNetworkImage remote probe =====');
    // ignore: avoid_print
    print('URL: $kProbeUrl');

    final response = await http.get(Uri.parse(kProbeUrl));

    // 1) Status code
    // ignore: avoid_print
    print('STATUS CODE   : ${response.statusCode} ${response.reasonPhrase}');

    // 2) content-type header
    // ignore: avoid_print
    print('CONTENT-TYPE  : ${response.headers['content-type']}');
    // ignore: avoid_print
    print('CONTENT-LENGTH: ${response.headers['content-length']}');
    // ignore: avoid_print
    print('SERVER        : ${response.headers['server']}');

    // 3) Body preview + magic-byte check
    final body = response.bodyBytes;
    final firstBytes = body.take(16).toList();
    final hexPreview =
        firstBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    // ignore: avoid_print
    print('BODY LENGTH   : ${body.length} bytes');
    // ignore: avoid_print
    print('FIRST 16 BYTES: [$hexPreview]');
    // ignore: avoid_print
    print('LOOKS LIKE IMAGE (magic bytes)? ${_looksLikeImage(body)}');

    final textPreview = utf8
        .decode(body.take(300).toList(), allowMalformed: true)
        .replaceAll('\n', ' ')
        .replaceAll('\r', ' ');
    // ignore: avoid_print
    print('TEXT PREVIEW  : $textPreview');
    // ignore: avoid_print
    print('========================================\n');

    // Assertion kept loose on purpose — this test is a probe, not a gate.
    expect(response.statusCode, 200);
  });
}
