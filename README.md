# Average Speed Tracker

A Flutter application that tracks your average speed while driving using GPS location services. The app provides real-time speed monitoring, distance calculation, and various driving metrics.

## Features

- **Real-time Speed Tracking**: Monitor your current speed in km/h
- **Average Speed Calculation**: Calculate average speed throughout your journey
- **Maximum Speed Recording**: Track your peak speed during the trip
- **Distance Measurement**: Calculate total distance traveled
- **Duration Timer**: Track the duration of your journey
- **Clean Material Design UI**: Intuitive dashboard with metric cards

## Screenshots

The app displays six key metrics in a grid layout:
- Current Speed (km/h)
- Average Speed (km/h)
- Maximum Speed (km/h)
- Total Distance (km)
- Duration (HH:MM:SS)
- Tracking Status

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
git clone https://github.com/yourusername/avgspeed.git
cd avgspeed
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
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