import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/speed_camera.dart';
import '../data/bulgarian_cameras.dart';
import '../services/camera_service.dart';

class SpeedMap extends StatefulWidget {
  final Position? currentPosition;
  final double currentSpeed;
  final int currentSpeedLimit;
  final List<CameraWarning> cameraWarnings;
  final AverageSpeedWarning? averageSpeedWarning;

  const SpeedMap({
    super.key,
    this.currentPosition,
    required this.currentSpeed,
    required this.currentSpeedLimit,
    required this.cameraWarnings,
    this.averageSpeedWarning,
  });

  @override
  State<SpeedMap> createState() => _SpeedMapState();
}

class _SpeedMapState extends State<SpeedMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  Set<Circle> _circles = {};
  
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(42.7339, 25.4858), // Center of Bulgaria
    zoom: 7.0,
  );

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  @override
  void didUpdateWidget(SpeedMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPosition != oldWidget.currentPosition ||
        widget.cameraWarnings != oldWidget.cameraWarnings) {
      _createMarkers();
      _updateCamera();
    }
  }

  void _createMarkers() {
    Set<Marker> markers = {};
    
    // Add current position marker
    if (widget.currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            widget.currentPosition!.latitude,
            widget.currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: '${widget.currentSpeed.toStringAsFixed(0)} km/h | Limit: ${widget.currentSpeedLimit} km/h',
          ),
        ),
      );
    }

    // Add speed camera markers
    for (SpeedCamera camera in BulgarianCameras.cameras) {
      BitmapDescriptor icon;
      Color circleColor;
      
      // Determine marker color based on camera type and proximity
      bool isNearby = widget.cameraWarnings.any((w) => w.camera.id == camera.id);
      
      switch (camera.type) {
        case CameraType.fixed:
          icon = BitmapDescriptor.defaultMarkerWithHue(
            isNearby ? BitmapDescriptor.hueRed : BitmapDescriptor.hueOrange
          );
          circleColor = isNearby ? Colors.red : Colors.orange;
          break;
        case CameraType.mobile:
          icon = BitmapDescriptor.defaultMarkerWithHue(
            isNearby ? BitmapDescriptor.hueRed : BitmapDescriptor.hueYellow
          );
          circleColor = isNearby ? Colors.red : Colors.yellow;
          break;
        case CameraType.averageStart:
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
          circleColor = Colors.green;
          break;
        case CameraType.averageEnd:
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
          circleColor = Colors.green;
          break;
        default:
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
          circleColor = Colors.orange;
      }

      markers.add(
        Marker(
          markerId: MarkerId(camera.id),
          position: LatLng(camera.latitude, camera.longitude),
          icon: icon,
          infoWindow: InfoWindow(
            title: camera.name,
            snippet: '${_getCameraTypeString(camera.type)} | ${camera.speedLimit} km/h\n${camera.description ?? camera.road ?? ''}',
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
      _createSpeedZoneOverlays();
    });
  }
  
  void _createSpeedZoneOverlays() {
    Set<Circle> circles = {};
    Set<Polyline> polylines = {};
    
    // Add warning circles around nearby cameras
    for (CameraWarning warning in widget.cameraWarnings) {
      Color circleColor;
      switch (warning.level) {
        case WarningLevel.critical:
          circleColor = Colors.red.withOpacity(0.3);
          break;
        case WarningLevel.high:
          circleColor = Colors.orange.withOpacity(0.3);
          break;
        case WarningLevel.medium:
          circleColor = Colors.yellow.withOpacity(0.2);
          break;
        case WarningLevel.low:
          circleColor = Colors.blue.withOpacity(0.2);
          break;
      }
      
      circles.add(
        Circle(
          circleId: CircleId('warning_${warning.camera.id}'),
          center: LatLng(warning.camera.latitude, warning.camera.longitude),
          radius: warning.distance,
          fillColor: circleColor,
          strokeColor: circleColor.withOpacity(0.8),
          strokeWidth: 2,
        ),
      );
    }
    
    // Add average speed zone polylines
    for (AverageSpeedZone zone in BulgarianCameras.averageSpeedZones) {
      polylines.add(
        Polyline(
          polylineId: PolylineId(zone.id),
          points: [
            LatLng(zone.startCamera.latitude, zone.startCamera.longitude),
            LatLng(zone.endCamera.latitude, zone.endCamera.longitude),
          ],
          color: widget.averageSpeedWarning?.zone.id == zone.id 
            ? Colors.red 
            : Colors.blue,
          width: 4,
          patterns: [PatternItem.dash(30), PatternItem.gap(10)],
        ),
      );
    }
    
    // Add speed limit zones (simplified rectangles)
    for (SpeedZone speedZone in BulgarianCameras.speedZones) {
      polylines.add(
        Polyline(
          polylineId: PolylineId('zone_${speedZone.road}'),
          points: [
            LatLng(speedZone.startLat, speedZone.startLon),
            LatLng(speedZone.endLat, speedZone.endLon),
          ],
          color: _getSpeedLimitColor(speedZone.speedLimit),
          width: 6,
          patterns: [PatternItem.dot, PatternItem.gap(10)],
        ),
      );
    }

    setState(() {
      _circles = circles;
      _polylines = polylines;
    });
  }
  
  Color _getSpeedLimitColor(int speedLimit) {
    if (speedLimit >= 130) return Colors.green;
    if (speedLimit >= 90) return Colors.blue;
    if (speedLimit >= 50) return Colors.orange;
    return Colors.red;
  }
  
  String _getCameraTypeString(CameraType type) {
    switch (type) {
      case CameraType.fixed:
        return 'Fixed Camera';
      case CameraType.mobile:
        return 'Mobile Camera';
      case CameraType.averageStart:
        return 'Avg Speed Start';
      case CameraType.averageEnd:
        return 'Avg Speed End';
      case CameraType.redLight:
        return 'Red Light';
    }
  }

  void _updateCamera() {
    if (_mapController != null && widget.currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              widget.currentPosition!.latitude,
              widget.currentPosition!.longitude,
            ),
            zoom: 14.0,
          ),
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // Set custom map style (optional)
    _setMapStyle();
    
    // Focus on current location if available
    if (widget.currentPosition != null) {
      _updateCamera();
    }
  }
  
  void _setMapStyle() async {
    String style = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]
    ''';
    
    _mapController?.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            polylines: _polylines,
            circles: _circles,
            myLocationEnabled: false, // We handle this manually
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          
          // Speed info overlay
          if (widget.currentPosition != null)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.currentSpeed.toStringAsFixed(0)} km/h',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.currentSpeed > widget.currentSpeedLimit 
                          ? Colors.red 
                          : Colors.green,
                      ),
                    ),
                    Text(
                      'Limit: ${widget.currentSpeedLimit} km/h',
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (widget.cameraWarnings.isNotEmpty)
                      Text(
                        'Camera: ${widget.cameraWarnings.first.distance.round()}m',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          
          // Map controls
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: "zoom_in",
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: "zoom_out",
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  heroTag: "my_location",
                  onPressed: widget.currentPosition != null ? _updateCamera : null,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
          
          // Legend
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Legend:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  _buildLegendItem(Colors.blue, 'Your Location'),
                  _buildLegendItem(Colors.orange, 'Fixed Camera'),
                  _buildLegendItem(Colors.yellow, 'Mobile Camera'),
                  _buildLegendItem(Colors.green, 'Average Speed'),
                  _buildLegendItem(Colors.red, 'Warning Zone'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}