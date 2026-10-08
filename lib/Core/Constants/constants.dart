class AppConstants {
  static const String baseUrl = 'https://api.nirvoor.com';
  static const String apiBaseUrl = '$baseUrl/api';
  // Uploads (Images/Videos/PDFs) are hosted by the API backend, NOT the
  // learning.nirvoor.com SPA. The SPA's catch-all route answers every
  // /uploads/* path with index.html (200 text/html), which crashes the mobile
  // image decoder. api.nirvoor.com serves the same paths as raw image bytes.
  static const String assetBaseUrl = 'https://api.nirvoor.com';
  
  static const String tokenKey = 'jwt_token';
  static const String userRoleKey = 'user_role';
  static const String userDataKey = 'user_data';

  // Static File URLs
  static const String imagesUrl = '$assetBaseUrl/uploads/Images/';
  static const String videosUrl = '$assetBaseUrl/uploads/Videos/';
  static const String pdfsUrl = '$assetBaseUrl/uploads/PDFs/';
}
