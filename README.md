# Speed Tracker BG 🇧🇬

**The Ultimate Driving Companion for Bulgarian Roads**

A comprehensive Flutter application designed specifically for Bulgarian roads that tracks your speed while driving and warns about speed cameras and speed limits. Stay safe, avoid fines, and drive with confidence using real-time GPS monitoring, intelligent speed camera detection, and interactive mapping.

## 🎯 Why Speed Tracker BG?

### **Drive Safer, Drive Smarter**
- **Avoid Costly Fines**: Get warned 1km before speed cameras and average speed zones
- **Stay Legal**: Real-time speed limit display ensures you never accidentally speed
- **Save Money**: Prevent expensive traffic violations with advance camera warnings
- **Peace of Mind**: Focus on driving while the app monitors your speed and surroundings

### **Built for Bulgaria 2025**
- **New Average Speed Zones**: First app to support Bulgaria's new toll-camera enforcement system
- **A2 Hemus Ready**: Complete coverage of Sofia-Varna route with Botevgrad and Veliko Tarnovo zones
- **Municipal Cameras**: Database includes Sofia, Plovdiv, and regional enforcement cameras
- **Real-time Updates**: Community-driven mobile camera alerts from fellow drivers

## 🚀 Key Features

### **Smart Speed Monitoring**
- **🎯 Instant Speed Display**: Large, color-coded current speed (green=safe, orange=warning, red=danger)
- **📊 Trip Analytics**: Track average speed, max speed, distance, and journey duration
- **🎯 Speed Limit Awareness**: Always know the current road's speed limit
- **📈 Performance Insights**: Analyze your driving patterns over time

### **Advanced Camera Detection System**
- **🚨 1km Early Warnings**: Visual and audio alerts before speed cameras
- **🎯 Smart Camera Types**: 
  - Fixed speed cameras (permanent installations)
  - Mobile speed traps (police units)
  - Average speed zones (toll camera sections)
  - Red light cameras
- **🔊 Voice Announcements**: Clear English audio warnings with distance and speed limit
- **👥 Community Alerts**: Real-time mobile camera reports from other drivers
- **📍 Precise Locations**: GPS-accurate camera positions with direction of enforcement

### **Revolutionary Average Speed Zone Support**
- **🆕 Industry First**: Only app supporting Bulgaria's new average speed enforcement
- **📏 Zone Tracking**: Enter/exit notifications with real-time average calculation
- **⚡ Smart Recommendations**: Suggests optimal speed to maintain legal average
- **🎯 Visual Indicators**: Clear zone boundaries and progress on map

### **Professional Interactive Mapping**
- **🗺️ Google Maps Integration**: High-quality satellite and road view mapping
- **📍 Live Location**: Real-time position with speed and limit overlay
- **🎨 Smart Visualization**:
  - Camera markers color-coded by proximity and type
  - Warning circles around nearby enforcement points  
  - Speed limit route overlays
  - Average speed zones as dashed lines
- **🎮 Intuitive Controls**: Easy zoom, pan, and location centering

### **Dual-Tab Interface**
- **📱 Dashboard View**: Focus on speed metrics and warnings
- **🗺️ Map View**: Visual navigation with camera locations
- **⚡ Instant Switching**: Toggle between views while driving
- **📊 Rich Metrics**: 6 comprehensive driving statistics cards

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

## TODO / Roadmap 🚧

### Upcoming Features
- [ ] **Commercial Data Integration**: Evaluate TomTom vs HERE Maps for enhanced camera database
- [ ] **Community Features**: 
  - [ ] User-reported mobile camera submissions with confidence scoring
  - [ ] Crowdsourced validation system for camera accuracy
  - [ ] Real-time community alerts network
- [ ] **Enhanced Average Speed Zones**: 
  - [ ] More Bulgarian toll sections (A1, A4 highways)
  - [ ] Historical average speed analytics
  - [ ] Speed recommendations for optimal fuel efficiency
- [ ] **Advanced Analytics**:
  - [ ] Trip history and driving patterns
  - [ ] Fuel consumption estimates based on speed
  - [ ] Carbon footprint tracking
- [ ] **Multi-language Support**: Bulgarian language interface
- [ ] **Offline Mode**: Continue tracking without internet connection
- [ ] **Integration**: 
  - [ ] Android Auto / Apple CarPlay support
  - [ ] OBD-II integration for vehicle data
- [ ] **Premium Features**:
  - [ ] Weather-based speed recommendations
  - [ ] Traffic-aware route optimization
  - [ ] Advanced reporting and exports

### Technical Improvements
- [ ] **Performance**: Optimize map rendering for smoother experience
- [ ] **Battery**: Implement power-efficient GPS tracking modes
- [ ] **Security**: Enhanced encryption for user data
- [ ] **Testing**: Comprehensive unit and integration test coverage

## License

This project is open source and available under the MIT License.

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

## Author

Created with Flutter and love for safe driving.

---

**Note**: This app is intended for passenger use or when the vehicle is safely parked. Please do not interact with the app while driving. Always prioritize road safety.