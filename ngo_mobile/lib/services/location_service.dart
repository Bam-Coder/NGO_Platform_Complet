import 'package:geolocator/geolocator.dart';

class LocationCoords {
  final double lat;
  final double lng;

  const LocationCoords({
    required this.lat,
    required this.lng,
  });
}

class LocationService {
  static Future<LocationCoords?> getCurrentCoords() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LocationCoords(
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (_) {
      return null;
    }
  }
}
