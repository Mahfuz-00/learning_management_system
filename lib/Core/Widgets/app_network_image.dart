import 'dart:async';
import 'dart:developer';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import '../Constants/app_constants.dart';

/// Decodes raw bytes as an image, but first verifies the bytes are actually an
/// image. Some servers mistakenly answer an image request with an HTML page
/// (e.g. the Angular `index.html` catch-all) or a JSON error body. If those
/// bytes were handed straight to the codec, Android would abort with
/// `Invalid image data` /
/// `ImageDecoder$DecodeException`. Rejecting them here turns a hard native
/// crash into a normal, catchable image error so the widget can show its
/// fallback instead.
class _SafeNetworkImage extends ImageProvider<_SafeNetworkImage> {
  const _SafeNetworkImage(this.url, this.scale);

  final String url;
  final double scale;

  /// True when the leading bytes match a known image container signature.
  static bool _hasImageMagicBytes(Uint8List bytes) {
    return AppNetworkImage.looksLikeImageBytes(bytes);
  }

  @override
  Future<_SafeNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_SafeNetworkImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      _SafeNetworkImage key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _load(key, decode),
      scale: key.scale,
      debugLabel: key.url,
    );
  }

  Future<ui.Codec> _load(
      _SafeNetworkImage key, ImageDecoderCallback decode) async {
    final response = await http.get(Uri.parse(key.url));
    if (response.statusCode != 200) {
      throw NetworkImageLoadException(
        statusCode: response.statusCode,
        uri: Uri.parse(key.url),
      );
    }

    final bytes = response.bodyBytes;
    final contentType =
        response.headers['content-type']?.toLowerCase() ?? '';

    // A server returning HTML/JSON for an image URL will not have image magic
    // bytes. Reject before the native decoder ever runs.
    if (!_hasImageMagicBytes(bytes)) {
      final preview = String.fromCharCodes(
        bytes.take(60),
      ).replaceAll(RegExp(r'\s+'), ' ');
      throw Exception(
        'Response is not a valid image for $url '
        '(status ${response.statusCode}, content-type "$contentType", '
        '${bytes.length} bytes, preview: "$preview"). '
        'The server likely returned an HTML/JSON page instead of image bytes.',
      );
    }

    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is _SafeNetworkImage && other.url == url && other.scale == scale;

  @override
  int get hashCode => Object.hash(url, scale);
}

/// Central network image loader with URL sanitization, SVG detection,
/// debug logging, and graceful decoding error fallback.
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  /// True when [bytes] start with a recognised image container signature
  /// (PNG, JPEG, GIF, BMP, WebP, HEIF/AVIF).
  ///
  /// Used to reject HTML/JSON error pages that some servers return for image
  /// URLs, so they never reach Android's native decoder (which would abort with
  /// `Invalid image data` / `ImageDecoder$DecodeException`).
  static bool looksLikeImageBytes(Uint8List bytes) {
    bool at(int i, int v) => bytes.length > i && bytes[i] == v;

    // PNG: 89 50 4E 47
    if (at(0, 0x89) && at(1, 0x50) && at(2, 0x4E) && at(3, 0x47)) return true;
    // JPEG: FF D8 FF
    if (at(0, 0xFF) && at(1, 0xD8) && at(2, 0xFF)) return true;
    // GIF: 47 49 46 38
    if (at(0, 0x47) && at(1, 0x49) && at(2, 0x46) && at(3, 0x38)) return true;
    // BMP: 42 4D
    if (at(0, 0x42) && at(1, 0x4D)) return true;
    // WEBP: RIFF....WEBP
    if (at(0, 0x52) && at(1, 0x49) && at(2, 0x46) && at(3, 0x46) &&
        at(8, 0x57) && at(9, 0x45) && at(10, 0x42) && at(11, 0x50)) {
      return true;
    }
    // HEIF/AVIF (ISO-BMFF): ....ftyp
    if (bytes.length > 11 &&
        at(4, 0x66) && at(5, 0x74) && at(6, 0x79) && at(7, 0x70)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = AppConstants.resolveImageUrl(imageUrl);

    // Step 2: Debug logging outputting exact URL loaded right before widget
    log('AppNetworkImage: Loading image URL: "$resolvedUrl" (raw input: "$imageUrl")');

    final defaultError = Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );

    final defaultPlaceholder = Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
    );

    if (resolvedUrl.isEmpty) {
      log('AppNetworkImage: Empty or invalid image path, displaying fallback placeholder.');
      Widget fallback = errorWidget ?? defaultError;
      if (borderRadius != null) {
        fallback = ClipRRect(borderRadius: borderRadius!, child: fallback);
      }
      return fallback;
    }

    Widget imageWidget;

    // Step 3: Switch SVGs to SvgPicture.network
    if (AppConstants.isSvgUrl(resolvedUrl)) {
      log('AppNetworkImage: SVG format detected for "$resolvedUrl", rendering via SvgPicture.network.');
      imageWidget = SvgPicture.network(
        resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => placeholder ?? defaultPlaceholder,
      );
    } else {
      // Step 4: Bitmap images (JPEG, PNG, WebP). The bytes are fetched and
      // validated by [_SafeNetworkImage] before decoding, so an HTML/JSON error
      // page returned for an image URL surfaces as a catchable error instead of
      // an Android `ImageDecoder$DecodeException` crash. `cached_network_image`
      // is intentionally NOT used here: its cache layer decodes the response
      // directly and would still crash on a non-image body.
      imageWidget = Image(
        image: _SafeNetworkImage(resolvedUrl, 1.0),
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return placeholder ?? defaultPlaceholder;
        },
        errorBuilder: (context, error, stackTrace) {
          log('AppNetworkImage: Failed to load bitmap "$resolvedUrl": $error');
          return errorWidget ?? defaultError;
        },
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }
}
