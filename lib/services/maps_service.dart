import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mrts/core/config/google_maps_config.dart';

class MapsService {
  final PolylinePoints _polylinePoints = PolylinePoints();

  Future<List<LatLng>> getDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final result = await _polylinePoints
          .getRouteBetweenCoordinates(
            googleApiKey: googleMapsApiKey,
            request: PolylineRequest(
              origin: PointLatLng(origin.latitude, origin.longitude),
              destination: PointLatLng(destination.latitude, destination.longitude),
              mode: TravelMode.driving,
            ),
          )
          .timeout(const Duration(seconds: 5));

      if (result.points.isEmpty) {
        return [origin, destination];
      }

      return result.points
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
    } catch (_) {
      return [origin, destination];
    }
  }
}
