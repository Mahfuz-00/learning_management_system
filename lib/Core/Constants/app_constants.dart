class AppConstants {
  static const String baseUrl = 'http://160.191.150.185:8071/api/';
  static const String assetBaseUrl = 'http://160.191.150.185:8071';
  
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
}
