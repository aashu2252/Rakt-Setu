// lib/core/utils/geo_utils.dart
import 'dart:math';

class GeoUtils {
  GeoUtils._();

  static const double earthRadiusKm = 6371.0;

  /// Haversine formula to compute distance between two coordinates in km
  static double distanceInKm(
      double lat1, double lon1, double lat2, double lon2) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  /// Formats distance to human-readable string
  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)}m away';
    return '${km.toStringAsFixed(1)} km away';
  }

  /// Returns bounding box for geo-queries: [minLat, maxLat, minLon, maxLon]
  static List<double> getBoundingBox(double lat, double lon, double radiusKm) {
    final latDelta = radiusKm / earthRadiusKm * (180 / pi);
    final lonDelta =
        radiusKm / (earthRadiusKm * cos(lat * pi / 180)) * (180 / pi);
    return [lat - latDelta, lat + latDelta, lon - lonDelta, lon + lonDelta];
  }
}
