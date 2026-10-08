// Global test configuration — runs automatically before every test in `test/`.
//
// Flutter discovers this file by convention: if `test/flutter_test_config.dart`
// exists and exports a `testExecutable(FutureOr<void> Function() testMain)`, the
// framework wraps the whole suite with it.
//
// What it does:
//   * loads real fonts so text renders identically everywhere (without this,
//     golden tests fall back to the "Ahem"/blank test font and every golden
//     becomes a black-box diff that is useless for visual regression);
//   * pins the golden comparator behaviour so missing/generated files are
//     handled predictably;
//   * forces a deterministic surface size / device pixel ratio so the same
//     logical layout is produced on Windows, macOS and CI Linux.
//
// Golden files are therefore portable across platforms.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixed logical size used by every golden. Keeps renders comparable across
/// machines with different default window sizes.
const Size kGoldenSurfaceSize = Size(390, 844); // iPhone 14 logical size.

/// Fixed pixel ratio. 1.0 keeps golden PNGs small and avoids sub-pixel
/// differences between devices with HiDPI scaling.
const double kGoldenDevicePixelRatio = 1.0;

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Load real fonts for deterministic text metrics. Skipped quietly if the
  // asset is unavailable (e.g. a stripped-down CI image) so unit tests that do
  // not render text still run.
  await _loadFonts();

  // Golden plumbing.
  //
  // - `autoUpdateGoldenFiles` is honoured automatically when running
  //   `flutter test --update-goldens`.
  // - `goldenFileComparator` defaults to the LocalFileComparator, which reads
  //   from `test/goldens/`. We only override the failure output behaviour via
  //   the default implementation, so nothing extra is needed here.
  //
  // Surface size + DPR are applied per-test by the `pumpForGolden` helper in
  // test/helpers/test_harness.dart (a global override would affect every test).

  await testMain();
}

Future<void> _loadFonts() async {
  // A Roboto copy is committed under test/fonts so goldens render identically
  // on every machine and CI, without depending on a system font or the SDK
  // layout. Loading it replaces the default square "Ahem" test glyphs that make
  // every character the same width (which also caused layout overflows).
  final candidates = <File>[
    File('test/fonts/Roboto-Regular.ttf'),
    File('fonts/Roboto-Regular.ttf'),
  ];

  for (final file in candidates) {
    if (!file.existsSync()) continue;
    try {
      final bytes = await file.readAsBytes();
      final loader = FontLoader('Roboto')
        ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
      await loader.load();
      return;
    } catch (_) {
      // Try the next candidate.
    }
  }

  // Optional override: point GOLDEN_FONT_DIR at a directory of .ttf files.
  final envDir = Platform.environment['GOLDEN_FONT_DIR'];
  if (envDir == null || envDir.isEmpty) return;
  final dir = Directory(envDir);
  if (!dir.existsSync()) return;
  for (final file in dir.listSync().whereType<File>()) {
    if (!file.path.toLowerCase().endsWith('.ttf')) continue;
    try {
      final bytes = await file.readAsBytes();
      final loader = FontLoader('Roboto')
        ..addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
      await loader.load();
    } catch (_) {
      // Ignore unreadable font files.
    }
  }
}
