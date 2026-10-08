class AppConstants {
  // static const String baseUrl = 'http://160.191.150.185:8071/api/';
  static const String baseUrl = 'https://api.nirvoor.com/api/';
  // Uploads (Images/Videos/PDFs) are hosted by the API backend, NOT the
  // learning.nirvoor.com SPA. The SPA's catch-all route answers every
  // /uploads/* path with index.html (200 text/html), which crashes the mobile
  // image decoder. api.nirvoor.com serves the same paths as raw image bytes.
  static const String assetBaseUrl = 'https://api.nirvoor.com';
  
  // Storage Keys
  static const String tokenKey = 'jwt_token';
  static const String userBox = 'user_box';
  static const String userDataKey = 'user_data';
  static const String userPreferencesKey = 'user_preferences';

  // Assets Paths
  static const String imagesPath = '$assetBaseUrl/uploads/Images/';
  static const String videosPath = '$assetBaseUrl/uploads/Videos/';
  static const String pdfsPath = '$assetBaseUrl/uploads/PDFs/';
  
  // Backward compatibility aliases
  static const String imagesBaseUrl = imagesPath;
  static const String videosBaseUrl = videosPath;
  static const String pdfsBaseUrl = pdfsPath;

  /// Resolves raw image path into a valid absolute URL.
  static String resolveImageUrl(String? rawPath) {
    if (rawPath == null) return '';
    var trimmed = rawPath.trim();
    if (trimmed.isEmpty ||
        trimmed == 'null' ||
        trimmed == 'undefined' ||
        trimmed == 'none' ||
        trimmed == 'false') {
      return '';
    }

    // Replace obsolete IP address if present in cached strings or backend payload
    if (trimmed.contains('160.191.150.185:8071')) {
      trimmed = trimmed.replaceFirst(
        RegExp(r'http://160\.191\.150\.185:8071(/api)?'),
        assetBaseUrl,
      );
    }

    // Rewrite absolute URLs that point at the SPA host (or its API sub-path)
    // onto the asset host. The backend stores some upload URLs as
    // `https://learning.nirvoor.com/uploads/...`, but that host answers every
    // /uploads/* request with the SPA's index.html (200 text/html) instead of
    // the file, which crashes Android's image decoder. The same path is served
    // correctly by api.nirvoor.com. Only /uploads/* URLs are rewritten so API
    // calls on that host are untouched.
    if (trimmed.contains('/uploads/')) {
      trimmed = trimmed.replaceFirst(
        RegExp(r'https?://[^/]+'),
        assetBaseUrl,
      );
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    if (cleanPath.startsWith('uploads/')) {
      return '$assetBaseUrl/$cleanPath';
    }
    return '$imagesPath$cleanPath';
  }

  /// True if the URL points to an SVG graphic.
  static bool isSvgUrl(String url) {
    final cleanUrl = url.toLowerCase().split('?').first;
    return cleanUrl.endsWith('.svg');
  }
}
