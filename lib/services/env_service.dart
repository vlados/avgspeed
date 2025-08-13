import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static bool _isInitialized = false;
  
  /// Initialize the environment service
  /// Call this before using any environment variables
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await dotenv.load(fileName: '.env');
      _isInitialized = true;
    } catch (e) {
      // Fallback: .env file might not exist in production
      // Use dart-define values or default values
      _isInitialized = true;
    }
  }
  
  /// Get Google Maps API key
  static String get googleMapsApiKey {
    // Try dart-define first (for production builds)
    const dartDefineKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (dartDefineKey.isNotEmpty) return dartDefineKey;
    
    // Fallback to .env file (for development)
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? 'YOUR_GOOGLE_MAPS_API_KEY';
  }
  
  /// Get app name
  static String get appName {
    const dartDefineValue = String.fromEnvironment('APP_NAME');
    if (dartDefineValue.isNotEmpty) return dartDefineValue;
    return dotenv.env['APP_NAME'] ?? 'Speed Tracker BG';
  }
  
  /// Get app version
  static String get appVersion {
    const dartDefineValue = String.fromEnvironment('APP_VERSION');
    if (dartDefineValue.isNotEmpty) return dartDefineValue;
    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }
  
  /// Check if debug mode is enabled
  static bool get isDebugMode {
    const dartDefineValue = String.fromEnvironment('DEBUG_MODE');
    if (dartDefineValue.isNotEmpty) return dartDefineValue.toLowerCase() == 'true';
    
    final envValue = dotenv.env['DEBUG_MODE']?.toLowerCase();
    return envValue == 'true';
  }
  
  /// Check if logs are enabled
  static bool get enableLogs {
    const dartDefineValue = String.fromEnvironment('ENABLE_LOGS');
    if (dartDefineValue.isNotEmpty) return dartDefineValue.toLowerCase() == 'true';
    
    final envValue = dotenv.env['ENABLE_LOGS']?.toLowerCase();
    return envValue == 'true';
  }
  
  /// Get camera API URL (if using external API)
  static String? get cameraApiUrl {
    const dartDefineValue = String.fromEnvironment('CAMERA_API_URL');
    if (dartDefineValue.isNotEmpty) return dartDefineValue;
    return dotenv.env['CAMERA_API_URL'];
  }
  
  /// Get API timeout in seconds
  static int get apiTimeout {
    const dartDefineValue = String.fromEnvironment('API_TIMEOUT');
    if (dartDefineValue.isNotEmpty) return int.tryParse(dartDefineValue) ?? 30;
    
    final envValue = dotenv.env['API_TIMEOUT'];
    return int.tryParse(envValue ?? '') ?? 30;
  }
  
  /// Check if all required environment variables are set
  static bool get isConfigurationValid {
    final apiKey = googleMapsApiKey;
    return apiKey != 'YOUR_GOOGLE_MAPS_API_KEY' && apiKey.isNotEmpty;
  }
  
  /// Get configuration summary for debugging
  static Map<String, dynamic> get configSummary {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'isDebugMode': isDebugMode,
      'enableLogs': enableLogs,
      'hasValidApiKey': isConfigurationValid,
      'cameraApiUrl': cameraApiUrl ?? 'Not set',
      'apiTimeout': apiTimeout,
    };
  }
}