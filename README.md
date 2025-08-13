# Speed Tracker BG 🇧🇬

A comprehensive Flutter application designed specifically for Bulgarian roads that tracks your speed while driving and warns about speed cameras and limits. Features real-time GPS monitoring, speed camera detection, and interactive mapping.

## Features

### Speed Tracking
- **Real-time Speed Tracking**: Monitor your current speed in km/h with color-coded display
- **Average Speed Calculation**: Calculate average speed throughout your journey
- **Maximum Speed Recording**: Track your peak speed during the trip
- **Distance Measurement**: Calculate total distance traveled using GPS coordinates
- **Duration Timer**: Track the duration of your journey with HH:MM:SS format

### Speed Camera & Limit System
- **Bulgarian Speed Camera Database**: 12+ camera locations along major routes (Sofia-Varna)
- **1km Advance Warnings**: Visual and audio alerts when approaching cameras
- **Average Speed Zones**: Botevgrad and Veliko Tarnovo sections with zone tracking
- **Dynamic Speed Limits**: Automatic speed limit detection based on road type and location
- **Audio Warnings**: Text-to-speech announcements in English
- **Visual Warning Banners**: Color-coded alerts (green/orange/red) based on proximity and speed

### Interactive Map
- **Google Maps Integration**: Real-time map with your current location
- **Speed Camera Markers**: All cameras marked with different colors based on type
  - Fixed cameras (orange/red)
  - Mobile cameras (yellow/red)
  - Average speed zone markers (green)
- **Warning Zones**: Proximity circles around nearby cameras
- **Speed Limit Overlays**: Road sections with different speed limits visualized
- **Route Visualization**: Average speed zones shown as dashed lines
- **Map Controls**: Zoom in/out and center on location buttons

## User Interface

### Tabbed Interface
The app features two main tabs:

#### Dashboard Tab
- **Large Speed Display**: Current speed with color coding (green=safe, orange=warning, red=over limit)
- **Speed Limit Indicator**: Current road speed limit in red bordered box
- **6 Metric Cards**:
  - Current Speed (km/h)
  - Average Speed (km/h) 
  - Maximum Speed (km/h)
  - Total Distance (km)
  - Duration (HH:MM:SS)
  - Cameras Nearby (count)

#### Map Tab
- **Interactive Google Map** with Bulgarian road network
- **Current Location Marker** (blue) with speed overlay
- **Speed Camera Markers** color-coded by type and proximity
- **Speed Limit Route Overlays** showing different road speed zones
- **Warning Circles** around cameras within detection range
- **Map Legend** explaining all markers and colors
- **Map Controls** for zoom and location centering

## Getting Started

### Prerequisites

- Flutter SDK (3.32.8 or later)
- Dart SDK (3.8.1 or later)
- iOS development tools (Xcode) for iOS deployment
- Android Studio for Android deployment
- Chrome browser for web testing

### Installation

1. Clone the repository:
```bash
git clone https://github.com/vlados/avgspeed.git
cd avgspeed
```

2. **Configure Google Maps API Key** (required for map functionality):
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable Maps SDK for Android, iOS, and JavaScript APIs
   - Create credentials (API Key) 
   - **Set up environment variables** (choose one method):

   **Method A: Using .env file (Development)**
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Edit .env and add your API key
   GOOGLE_MAPS_API_KEY=your_actual_api_key_here
   ```

   **Method B: Using dart-define (Production)**
   ```bash
   # Run with dart-define
   flutter run --dart-define=GOOGLE_MAPS_API_KEY=your_actual_api_key_here
   
   # Build for production
   flutter build apk --dart-define=GOOGLE_MAPS_API_KEY=your_actual_api_key_here
   ```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
# For iOS Simulator
flutter run -d ios

# For Android
flutter run -d android

# For Web (Chrome)
flutter run -d chrome
```

## Platform Configuration

### iOS Setup
The app requires location permissions. The following permissions are already configured in `ios/Runner/Info.plist`:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysUsageDescription`
- Background location updates

### Android Setup
The following permissions are configured in `android/app/src/main/AndroidManifest.xml`:
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION`
- `FOREGROUND_SERVICE`
- `FOREGROUND_SERVICE_LOCATION`

## Usage

1. **Start Tracking**: Tap the "Start" button to begin GPS tracking
2. **Grant Permissions**: Allow location access when prompted
3. **Monitor Metrics**: View real-time updates of all driving metrics
4. **Stop Tracking**: Tap "Stop" to pause tracking
5. **Reset Data**: Tap "Reset" to clear all data for a new session

## Dependencies

- `geolocator: ^14.0.2` - GPS location services
- `permission_handler: ^12.0.1` - Permission management
- `flutter/material.dart` - Material Design components

## Technical Details

### Speed Calculation
- Speed is calculated from GPS position updates
- Converted from m/s to km/h for display
- Updates every 5 meters of movement (configurable)

### Distance Calculation
- Uses Haversine formula via Geolocator
- Calculates distance between consecutive GPS points
- Accumulates total distance in kilometers

### Average Speed
- Calculated from all speed readings during the session
- Filters out invalid readings (negative speeds)
- Updates in real-time as new data arrives

## Privacy & Permissions

This app requires location permissions to function. Location data is:
- Only used locally on your device
- Not transmitted to any servers
- Not stored permanently
- Only active while the app is in use

## Environment Variables & Security

The app uses environment variables to securely manage sensitive configuration:

### Available Variables
- `GOOGLE_MAPS_API_KEY`: Google Maps API key (required)
- `APP_NAME`: Application display name
- `APP_VERSION`: Application version
- `DEBUG_MODE`: Enable debug logging (true/false)
- `ENABLE_LOGS`: Enable console logs (true/false)

### Security Benefits
- **API Keys Protected**: No hardcoded API keys in source code
- **Git Safe**: `.env` file is excluded from version control
- **Environment Specific**: Different keys for development/production
- **Easy Management**: Single place to manage all configuration

## Building for Production

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
```

### Web
```bash
flutter build web --release
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the MIT License.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

## Author

Created with Flutter and love for safe driving.

---

**Note**: This app is intended for passenger use or when the vehicle is safely parked. Please do not interact with the app while driving. Always prioritize road safety.