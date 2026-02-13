class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://192.168.100.47:3000',
  );

  // Auth endpoints
  static const String login = '/auth/login';
  
  // Projects endpoints
  static const String projects = '/projects';
  
  // Expenses endpoints
  static const String expenses = '/expenses';
  
  // Reports endpoints
  static const String impactReports = '/impact-reports';
}

class UploadConstants {
  // Cloudinary unsigned upload config
  // TODO: Replace with your real Cloudinary values.
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'YOUR_UNSIGNED_PRESET';
  static const String folder = 'ngo-app';
}
