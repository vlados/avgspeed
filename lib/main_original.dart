import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Average Speed Tracker',
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

class _SpeedTrackerScreenState extends State<SpeedTrackerScreen> {
  bool _isTracking = false;
  double _currentSpeed = 0.0;
  double _averageSpeed = 0.0;
  double _maxSpeed = 0.0;
  double _totalDistance = 0.0;
  int _trackingDuration = 0;
  
  List<double> _speedReadings = [];
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _timer;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
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
            'This app needs location permission to track your speed.'),
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
    });

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
    });
  }

  void _updateSpeed(Position position) {
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
      });
    }
  }

  void _stopTracking() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    setState(() {
      _isTracking = false;
    });
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

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Average Speed Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMetricCard(
                    'Current Speed',
                    '${_currentSpeed.toStringAsFixed(1)} km/h',
                    Icons.speed,
                    Colors.blue,
                  ),
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
                    'Status',
                    _isTracking ? 'Tracking' : 'Stopped',
                    _isTracking ? Icons.gps_fixed : Icons.gps_off,
                    _isTracking ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
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
          ],
        ),
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