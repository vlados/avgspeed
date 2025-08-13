import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'services/camera_service.dart';
import 'models/speed_camera.dart';
import 'widgets/speed_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speed Tracker BG',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SpeedTrackerScreen(),
    );
  }
}

class SpeedTrackerScreen extends StatefulWidget {
  const SpeedTrackerScreen({super.key});

  @override
  State<SpeedTrackerScreen> createState() => _SpeedTrackerScreenState();
}

class _SpeedTrackerScreenState extends State<SpeedTrackerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isTracking = false;
  double _currentSpeed = 0.0;
  double _averageSpeed = 0.0;
  double _maxSpeed = 0.0;
  double _totalDistance = 0.0;
  int _trackingDuration = 0;
  int _currentSpeedLimit = 90;
  
  List<double> _speedReadings = [];
  Position? _lastPosition;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _timer;
  DateTime? _startTime;
  
  // Camera detection
  final CameraService _cameraService = CameraService();
  List<CameraWarning> _cameraWarnings = [];
  AverageSpeedWarning? _averageSpeedWarning;
  
  // Audio
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _audioEnabled = true;
  DateTime? _lastWarningTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkPermissions();
    _initializeTTS();
  }
  
  Future<void> _initializeTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
  }

  Future<void> _checkPermissions() async {
    final locationPermission = await Permission.location.status;
    if (!locationPermission.isGranted) {
      final result = await Permission.location.request();
      if (!result.isGranted) {
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'This app needs location permission to track your speed and warn about cameras.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _startTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showServiceDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
      return;
    }

    setState(() {
      _isTracking = true;
      _speedReadings.clear();
      _currentSpeed = 0.0;
      _averageSpeed = 0.0;
      _maxSpeed = 0.0;
      _totalDistance = 0.0;
      _trackingDuration = 0;
      _startTime = DateTime.now();
      _cameraWarnings.clear();
      _averageSpeedWarning = null;
    });
    
    // Announce start
    if (_audioEnabled) {
      await _tts.speak("Speed tracking started. Drive safely.");
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _trackingDuration++;
      });
    });

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      _updateSpeed(position);
      _checkForSpeedCameras(position);
    });
  }

  void _updateSpeed(Position position) {
    setState(() {
      _currentPosition = position;
    });
    
    final speedInMps = position.speed;
    final speedInKmh = speedInMps * 3.6;

    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      _totalDistance += distance / 1000;
    }

    _lastPosition = position;

    if (speedInKmh >= 0) {
      _speedReadings.add(speedInKmh);
      
      setState(() {
        _currentSpeed = speedInKmh;
        _maxSpeed = speedInKmh > _maxSpeed ? speedInKmh : _maxSpeed;
        
        if (_speedReadings.isNotEmpty) {
          double sum = 0;
          for (var speed in _speedReadings) {
            sum += speed;
          }
          _averageSpeed = sum / _speedReadings.length;
        }
        
        // Update current speed limit
        _currentSpeedLimit = _cameraService.getCurrentSpeedLimit(position);
      });
    }
  }
  
  void _checkForSpeedCameras(Position position) {
    // Check for regular cameras
    List<CameraWarning> warnings = _cameraService.checkForCameras(position, _currentSpeed);
    
    // Check for average speed zones
    AverageSpeedWarning? avgWarning = _cameraService.checkAverageSpeedZone(position, _currentSpeed);
    
    setState(() {
      _cameraWarnings = warnings;
      _averageSpeedWarning = avgWarning;
    });
    
    // Audio warnings
    if (_audioEnabled) {
      _handleAudioWarnings(warnings, avgWarning);
    }
  }
  
  void _handleAudioWarnings(List<CameraWarning> warnings, AverageSpeedWarning? avgWarning) async {
    DateTime now = DateTime.now();
    
    // Limit warnings to once every 10 seconds
    if (_lastWarningTime != null && now.difference(_lastWarningTime!).inSeconds < 10) {
      return;
    }
    
    // Camera warnings
    if (warnings.isNotEmpty) {
      CameraWarning nearest = warnings.first;
      String message = "";
      
      if (nearest.isOverSpeed && nearest.level == WarningLevel.critical) {
        message = "Warning! Speed camera ahead. Reduce speed now!";
        // Play alert sound
        await _audioPlayer.play(AssetSource('sounds/warning.mp3')).catchError((e) {});
      } else if (nearest.level == WarningLevel.high) {
        message = "Speed camera in ${nearest.distance.round()} meters. Speed limit ${nearest.speedLimit} kilometers per hour.";
      } else if (nearest.level == WarningLevel.medium && nearest.isOverSpeed) {
        message = "Approaching camera. Current speed ${_currentSpeed.round()}. Limit ${nearest.speedLimit}.";
      }
      
      if (message.isNotEmpty) {
        await _tts.speak(message);
        _lastWarningTime = now;
      }
    }
    
    // Average speed zone warnings
    if (avgWarning != null) {
      String message = "";
      
      if (avgWarning.isEntering) {
        message = "Entering average speed zone. ${avgWarning.zone.distance} kilometers. Speed limit ${avgWarning.zone.speedLimit}.";
      } else if (avgWarning.isExiting) {
        if (avgWarning.averageSpeed > avgWarning.zone.speedLimit) {
          message = "Warning! Average speed ${avgWarning.averageSpeed} exceeds limit!";
        } else {
          message = "Exiting average speed zone. Average was ${avgWarning.averageSpeed}.";
        }
      } else if (avgWarning.averageSpeed > avgWarning.zone.speedLimit) {
        message = "Average speed too high! Recommended speed: ${avgWarning.recommendedSpeed}";
      }
      
      if (message.isNotEmpty) {
        await _tts.speak(message);
        _lastWarningTime = now;
      }
    }
  }

  void _stopTracking() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    setState(() {
      _isTracking = false;
    });
    
    if (_audioEnabled) {
      _tts.speak("Tracking stopped.");
    }
  }

  void _resetData() {
    setState(() {
      _currentSpeed = 0.0;
      _averageSpeed = 0.0;
      _maxSpeed = 0.0;
      _totalDistance = 0.0;
      _trackingDuration = 0;
      _speedReadings.clear();
      _lastPosition = null;
      _cameraWarnings.clear();
      _averageSpeedWarning = null;
    });
  }

  void _showServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Service Disabled'),
        content: const Text(
            'Please enable location services to track your speed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  Color _getSpeedColor() {
    if (_currentSpeed > _currentSpeedLimit) {
      return Colors.red;
    } else if (_currentSpeed > _currentSpeedLimit - 10) {
      return Colors.orange;
    }
    return Colors.green;
  }
  
  Widget _buildWarningBanner() {
    if (_cameraWarnings.isEmpty && _averageSpeedWarning == null) {
      return const SizedBox.shrink();
    }
    
    Color bannerColor = Colors.green;
    IconData icon = Icons.info;
    String message = "";
    
    // Priority: Average speed zone warnings
    if (_averageSpeedWarning != null) {
      if (_averageSpeedWarning!.isEntering) {
        bannerColor = Colors.blue;
        icon = Icons.login;
        message = "Entering ${_averageSpeedWarning!.zone.name} - ${_averageSpeedWarning!.zone.distance}km avg zone";
      } else if (_averageSpeedWarning!.isExiting) {
        bannerColor = _averageSpeedWarning!.averageSpeed > _averageSpeedWarning!.zone.speedLimit 
          ? Colors.red : Colors.green;
        icon = Icons.logout;
        message = "Exiting zone - Avg: ${_averageSpeedWarning!.averageSpeed} km/h";
      } else {
        bannerColor = _averageSpeedWarning!.averageSpeed > _averageSpeedWarning!.zone.speedLimit 
          ? Colors.orange : Colors.blue;
        icon = Icons.speed;
        message = "In avg zone - Current avg: ${_averageSpeedWarning!.averageSpeed} km/h";
      }
    }
    // Camera warnings
    else if (_cameraWarnings.isNotEmpty) {
      CameraWarning nearest = _cameraWarnings.first;
      if (nearest.level == WarningLevel.critical) {
        bannerColor = Colors.red;
        icon = Icons.warning;
      } else if (nearest.level == WarningLevel.high) {
        bannerColor = Colors.orange;
        icon = Icons.camera_alt;
      } else {
        bannerColor = Colors.yellow.shade700;
        icon = Icons.info;
      }
      
      String cameraType = nearest.camera.type == CameraType.fixed ? "Fixed camera" : "Mobile camera";
      message = "$cameraType in ${nearest.distance.round()}m - Limit: ${nearest.speedLimit} km/h";
    }
    
    return Container(
      color: bannerColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Column(
      children: [
        // Warning banner
        _buildWarningBanner(),
        
        // Speed limit indicator
        Container(
          padding: const EdgeInsets.all(16),
          color: _getSpeedColor().withOpacity(0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    '${_currentSpeed.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getSpeedColor(),
                    ),
                  ),
                  const Text('Current Speed'),
                ],
              ),
              const SizedBox(width: 40),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_currentSpeedLimit',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Text('Speed Limit'),
                ],
              ),
            ],
          ),
        ),
        
        // Metrics grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMetricCard(
                  'Average Speed',
                  '${_averageSpeed.toStringAsFixed(1)} km/h',
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildMetricCard(
                  'Max Speed',
                  '${_maxSpeed.toStringAsFixed(1)} km/h',
                  Icons.flash_on,
                  Colors.orange,
                ),
                _buildMetricCard(
                  'Distance',
                  '${_totalDistance.toStringAsFixed(2)} km',
                  Icons.straighten,
                  Colors.purple,
                ),
                _buildMetricCard(
                  'Duration',
                  _formatDuration(_trackingDuration),
                  Icons.timer,
                  Colors.teal,
                ),
                _buildMetricCard(
                  'Cameras Nearby',
                  '${_cameraWarnings.length}',
                  Icons.camera_alt,
                  _cameraWarnings.isNotEmpty ? Colors.red : Colors.grey,
                ),
                _buildMetricCard(
                  'Status',
                  _isTracking ? 'Tracking' : 'Stopped',
                  _isTracking ? Icons.gps_fixed : Icons.gps_off,
                  _isTracking ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapTab() {
    return Column(
      children: [
        // Warning banner
        _buildWarningBanner(),
        
        // Map
        Expanded(
          child: SpeedMap(
            currentPosition: _currentPosition,
            currentSpeed: _currentSpeed,
            currentSpeedLimit: _currentSpeedLimit,
            cameraWarnings: _cameraWarnings,
            averageSpeedWarning: _averageSpeedWarning,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    _tabController.dispose();
    _tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Speed Tracker BG'),
        actions: [
          IconButton(
            icon: Icon(_audioEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                _audioEnabled = !_audioEnabled;
              });
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.map), text: 'Map'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildMapTab(),
              ],
            ),
          ),
          
          // Control buttons
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isTracking ? null : _startTracking,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isTracking ? _stopTracking : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: !_isTracking ? _resetData : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}