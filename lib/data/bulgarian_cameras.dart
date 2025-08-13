import '../models/speed_camera.dart';

class BulgarianCameras {
  // Sofia-Varna (A2 Hemus) motorway cameras and average speed zones
  static final List<SpeedCamera> cameras = [
    // Sofia area
    SpeedCamera(
      id: 'sf_ring_1',
      name: 'Sofia Ring Road Exit',
      latitude: 42.7245,
      longitude: 23.4024,
      speedLimit: 90,
      type: CameraType.fixed,
      road: 'Sofia Ring Road',
      description: 'Exit towards A2 Hemus',
    ),
    
    // A2 Hemus motorway cameras (Sofia to Varna)
    SpeedCamera(
      id: 'a2_km15',
      name: 'A2 km 15',
      latitude: 42.7489,
      longitude: 23.4912,
      speedLimit: 140,
      type: CameraType.fixed,
      road: 'A2 Hemus',
    ),
    
    SpeedCamera(
      id: 'a2_botevgrad_avg_start',
      name: 'Botevgrad Average Speed Start',
      latitude: 42.9167,
      longitude: 23.7833,
      speedLimit: 130,
      type: CameraType.averageStart,
      road: 'A2 Hemus',
      description: 'Start of average speed zone',
    ),
    
    SpeedCamera(
      id: 'a2_botevgrad_avg_end',
      name: 'Botevgrad Average Speed End',
      latitude: 42.9547,
      longitude: 23.8912,
      speedLimit: 130,
      type: CameraType.averageEnd,
      road: 'A2 Hemus',
      description: 'End of average speed zone - 12km section',
    ),
    
    SpeedCamera(
      id: 'a2_pravets',
      name: 'Pravets',
      latitude: 42.9892,
      longitude: 23.9234,
      speedLimit: 140,
      type: CameraType.fixed,
      road: 'A2 Hemus',
    ),
    
    SpeedCamera(
      id: 'a2_jablanitsa',
      name: 'Jablanitsa',
      latitude: 43.0312,
      longitude: 24.0123,
      speedLimit: 90,
      type: CameraType.fixed,
      road: 'A2 Hemus',
      description: 'Reduced speed zone - curves',
    ),
    
    // Lovech area
    SpeedCamera(
      id: 'lovech_bypass',
      name: 'Lovech Bypass',
      latitude: 43.1367,
      longitude: 24.7169,
      speedLimit: 90,
      type: CameraType.fixed,
      road: 'E83',
    ),
    
    // Veliko Tarnovo area
    SpeedCamera(
      id: 'vt_avg_start',
      name: 'Veliko Tarnovo Average Speed Start',
      latitude: 43.0756,
      longitude: 25.6172,
      speedLimit: 90,
      type: CameraType.averageStart,
      road: 'E85',
      description: 'Start of 8km average speed zone',
    ),
    
    SpeedCamera(
      id: 'vt_avg_end',
      name: 'Veliko Tarnovo Average Speed End',
      latitude: 43.0912,
      longitude: 25.6892,
      speedLimit: 90,
      type: CameraType.averageEnd,
      road: 'E85',
    ),
    
    // Shumen area
    SpeedCamera(
      id: 'shumen_entrance',
      name: 'Shumen Entrance',
      latitude: 43.2706,
      longitude: 26.9291,
      speedLimit: 50,
      type: CameraType.fixed,
      road: 'E70',
      description: 'City entrance - speed trap',
    ),
    
    // Varna approach
    SpeedCamera(
      id: 'a2_devnya',
      name: 'Devnya',
      latitude: 43.2223,
      longitude: 27.5689,
      speedLimit: 90,
      type: CameraType.fixed,
      road: 'A2 Hemus',
    ),
    
    SpeedCamera(
      id: 'varna_entrance',
      name: 'Varna City Entrance',
      latitude: 43.2141,
      longitude: 27.8901,
      speedLimit: 50,
      type: CameraType.fixed,
      road: 'A2/E70',
      description: 'City limit - reduce speed',
    ),
  ];

  static final List<AverageSpeedZone> averageSpeedZones = [
    AverageSpeedZone(
      id: 'avg_botevgrad',
      name: 'Botevgrad Section',
      startCamera: cameras.firstWhere((c) => c.id == 'a2_botevgrad_avg_start'),
      endCamera: cameras.firstWhere((c) => c.id == 'a2_botevgrad_avg_end'),
      distance: 12.0,
      speedLimit: 130,
      road: 'A2 Hemus',
    ),
    AverageSpeedZone(
      id: 'avg_vt',
      name: 'Veliko Tarnovo Section',
      startCamera: cameras.firstWhere((c) => c.id == 'vt_avg_start'),
      endCamera: cameras.firstWhere((c) => c.id == 'vt_avg_end'),
      distance: 8.0,
      speedLimit: 90,
      road: 'E85',
    ),
  ];

  // Speed limits for different road types in Bulgaria
  static const Map<String, int> roadSpeedLimits = {
    'motorway': 140,
    'motorway_rain': 110,
    'expressway': 120,
    'national_road': 90,
    'urban': 50,
    'residential': 30,
  };

  // Major road sections with specific speed limits
  static final List<SpeedZone> speedZones = [
    SpeedZone(
      road: 'A2 Hemus - Sofia Section',
      speedLimit: 140,
      startLat: 42.6977,
      startLon: 23.3219,
      endLat: 42.9167,
      endLon: 23.7833,
    ),
    SpeedZone(
      road: 'A2 Hemus - Mountain Section',
      speedLimit: 90,
      startLat: 42.9892,
      startLon: 23.9234,
      endLat: 43.0512,
      endLon: 24.1234,
    ),
    SpeedZone(
      road: 'E83 - Lovech Area',
      speedLimit: 90,
      startLat: 43.0512,
      startLon: 24.1234,
      endLat: 43.2367,
      endLon: 24.8169,
    ),
    SpeedZone(
      road: 'E85 - Veliko Tarnovo',
      speedLimit: 90,
      startLat: 43.0256,
      startLon: 25.5172,
      endLat: 43.1912,
      endLon: 25.7892,
    ),
    SpeedZone(
      road: 'E70 - Shumen to Varna',
      speedLimit: 90,
      startLat: 43.2706,
      startLon: 26.9291,
      endLat: 43.2141,
      endLon: 27.8901,
    ),
  ];
}