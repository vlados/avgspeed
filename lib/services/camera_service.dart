import 'dart:math';
import 'package:geolocator/geolocator.dart';
import '../models/speed_camera.dart';
import '../data/bulgarian_cameras.dart';

class CameraService {
  static const double warningDistanceMeters = 1000; // Warn 1km before camera
  static const double proximityDistanceMeters = 300; // Very close to camera
  
  List<SpeedCamera> nearbyCameras = [];
  AverageSpeedZone? currentAverageZone;
  DateTime? averageZoneEntryTime;
  Position? averageZoneEntryPosition;
  
  // Calculate distance between two points using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
  
  // Check for nearby cameras
  List<CameraWarning> checkForCameras(Position currentPosition, double currentSpeed) {
    List<CameraWarning> warnings = [];
    
    for (SpeedCamera camera in BulgarianCameras.cameras) {
      double distance = calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        camera.latitude,
        camera.longitude,
      );
      
      if (distance <= warningDistanceMeters) {
        // Calculate bearing to camera
        double bearing = Geolocator.bearingBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          camera.latitude,
          camera.longitude,
        );
        
        // Check if we're approaching the camera (bearing within 45 degrees of heading)
        double headingDiff = (currentPosition.heading - bearing).abs();
        if (headingDiff > 180) headingDiff = 360 - headingDiff;
        
        if (headingDiff < 45) {
          WarningLevel level;
          if (distance <= proximityDistanceMeters) {
            level = WarningLevel.critical;
          } else if (distance <= 500) {
            level = WarningLevel.high;
          } else {
            level = WarningLevel.medium;
          }
          
          warnings.add(CameraWarning(
            camera: camera,
            distance: distance,
            speedLimit: camera.speedLimit,
            currentSpeed: currentSpeed.round(),
            level: level,
            isOverSpeed: currentSpeed > camera.speedLimit,
          ));
        }
      }
    }
    
    // Sort by distance
    warnings.sort((a, b) => a.distance.compareTo(b.distance));
    
    return warnings;
  }
  
  // Check for average speed zones
  AverageSpeedWarning? checkAverageSpeedZone(Position currentPosition, double currentSpeed) {
    for (AverageSpeedZone zone in BulgarianCameras.averageSpeedZones) {
      // Check if entering zone
      double distanceToStart = calculateDistance(
        currentPosition.latitude,
        currentPosition.longitude,
        zone.startCamera.latitude,
        zone.startCamera.longitude,
      );
      
      if (distanceToStart < 100 && currentAverageZone == null) {
        // Entering average speed zone
        currentAverageZone = zone;
        averageZoneEntryTime = DateTime.now();
        averageZoneEntryPosition = currentPosition;
        
        return AverageSpeedWarning(
          zone: zone,
          isEntering: true,
          isExiting: false,
          currentSpeed: currentSpeed.round(),
          averageSpeed: 0,
          recommendedSpeed: zone.speedLimit,
        );
      }
      
      // Check if in zone
      if (currentAverageZone?.id == zone.id) {
        double distanceToEnd = calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          zone.endCamera.latitude,
          zone.endCamera.longitude,
        );
        
        if (distanceToEnd < 100) {
          // Exiting zone - calculate average speed
          if (averageZoneEntryTime != null && averageZoneEntryPosition != null) {
            Duration timeInZone = DateTime.now().difference(averageZoneEntryTime!);
            double avgSpeed = (zone.distance * 1000) / timeInZone.inSeconds * 3.6;
            
            AverageSpeedWarning warning = AverageSpeedWarning(
              zone: zone,
              isEntering: false,
              isExiting: true,
              currentSpeed: currentSpeed.round(),
              averageSpeed: avgSpeed.round(),
              recommendedSpeed: zone.speedLimit,
            );
            
            // Reset zone tracking
            currentAverageZone = null;
            averageZoneEntryTime = null;
            averageZoneEntryPosition = null;
            
            return warning;
          }
        } else {
          // Still in zone - calculate current average
          if (averageZoneEntryTime != null && averageZoneEntryPosition != null) {
            Duration timeInZone = DateTime.now().difference(averageZoneEntryTime!);
            double distanceCovered = calculateDistance(
              averageZoneEntryPosition!.latitude,
              averageZoneEntryPosition!.longitude,
              currentPosition.latitude,
              currentPosition.longitude,
            ) / 1000; // Convert to km
            
            double avgSpeed = timeInZone.inSeconds > 0 
              ? (distanceCovered / timeInZone.inSeconds) * 3600 
              : 0;
            
            // Calculate recommended speed to maintain legal average
            double remainingDistance = zone.distance - distanceCovered;
            double maxTimeRemaining = (zone.distance / zone.speedLimit) * 3600 - timeInZone.inSeconds;
            double recommendedSpeed = maxTimeRemaining > 0
              ? (remainingDistance / maxTimeRemaining) * 3600
              : zone.speedLimit.toDouble();
            
            return AverageSpeedWarning(
              zone: zone,
              isEntering: false,
              isExiting: false,
              currentSpeed: currentSpeed.round(),
              averageSpeed: avgSpeed.round(),
              recommendedSpeed: recommendedSpeed.round(),
            );
          }
        }
      }
    }
    
    return null;
  }
  
  // Get current speed limit based on location
  int getCurrentSpeedLimit(Position position) {
    // Check if in a specific speed zone
    for (SpeedZone zone in BulgarianCameras.speedZones) {
      if (_isInZone(position, zone)) {
        return zone.speedLimit;
      }
    }
    
    // Default to general road type limits
    // This would need more sophisticated logic with map data
    return BulgarianCameras.roadSpeedLimits['national_road'] ?? 90;
  }
  
  bool _isInZone(Position position, SpeedZone zone) {
    // Simple rectangular zone check
    double lat = position.latitude;
    double lon = position.longitude;
    
    double minLat = min(zone.startLat, zone.endLat);
    double maxLat = max(zone.startLat, zone.endLat);
    double minLon = min(zone.startLon, zone.endLon);
    double maxLon = max(zone.startLon, zone.endLon);
    
    return lat >= minLat && lat <= maxLat && lon >= minLon && lon <= maxLon;
  }
}

class CameraWarning {
  final SpeedCamera camera;
  final double distance;
  final int speedLimit;
  final int currentSpeed;
  final WarningLevel level;
  final bool isOverSpeed;

  CameraWarning({
    required this.camera,
    required this.distance,
    required this.speedLimit,
    required this.currentSpeed,
    required this.level,
    required this.isOverSpeed,
  });
}

class AverageSpeedWarning {
  final AverageSpeedZone zone;
  final bool isEntering;
  final bool isExiting;
  final int currentSpeed;
  final int averageSpeed;
  final int recommendedSpeed;

  AverageSpeedWarning({
    required this.zone,
    required this.isEntering,
    required this.isExiting,
    required this.currentSpeed,
    required this.averageSpeed,
    required this.recommendedSpeed,
  });
}

enum WarningLevel {
  low,
  medium,
  high,
  critical,
}