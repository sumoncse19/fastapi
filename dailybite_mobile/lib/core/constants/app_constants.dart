class AppConstants {
  static const String appName = 'DailyBite';
  static const String appVersion = '1.0.0';
  
  // API Configuration - can be overridden via environment
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  static const String apiPrefix = '/api';
  static const String authPrefix = '/auth';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String userDataKey = 'user_data';
  static const String calorieGoalKey = 'calorie_goal';
  
  // Default Values
  static const int defaultCalorieGoal = 2000;
  static const int maxCalorieGoal = 5000;
  static const int minCalorieGoal = 1000;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Image Upload
  static const int maxImageSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'heic'];
}
