class SpeedCamera {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int speedLimit; // km/h
  final CameraType type;
  final String? description;
  final String? road;

  SpeedCamera({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.speedLimit,
    required this.type,
    this.description,
    this.road,
  });
}

enum CameraType {
  fixed,
  mobile,
  averageStart,
  averageEnd,
  redLight,
}

class AverageSpeedZone {
  final String id;
  final String name;
  final SpeedCamera startCamera;
  final SpeedCamera endCamera;
  final double distance; // km
  final int speedLimit; // km/h
  final String road;

  AverageSpeedZone({
    required this.id,
    required this.name,
    required this.startCamera,
    required this.endCamera,
    required this.distance,
    required this.speedLimit,
    required this.road,
  });
}

class SpeedZone {
  final String road;
  final int speedLimit;
  final double startLat;
  final double startLon;
  final double endLat;
  final double endLon;

  SpeedZone({
    required this.road,
    required this.speedLimit,
    required this.startLat,
    required this.startLon,
    required this.endLat,
    required this.endLon,
  });
}