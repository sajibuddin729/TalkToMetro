import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mrts/data/metro_stations.dart';

class MetroMapController extends GetxController {
  GoogleMapController? mapController;

  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  static const CameraPosition initialCamera = CameraPosition(
    target: LatLng(23.822350, 90.375000),
    zoom: 11.5,
  );

  @override
  void onInit() {
    super.onInit();
    _loadMetroLine();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(initialCamera),
    );
  }

  void _loadMetroLine() {
    markers.assignAll(
      dhakaMetroStations.map(
        (s) => Marker(
          markerId: MarkerId(s.name),
          position: s.position,
          infoWindow: InfoWindow(
            title: s.name,
            snippet: 'Dhaka Metro Rail',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      ),
    );

    polylines.assignAll({
      Polyline(
        polylineId: const PolylineId('metro_line'),
        color: const Color(0xFF2E7D32),
        width: 4,
        points: metroLineCoordinates,
      ),
    });
  }

  void focusStation(String name) {
    final station = metroStationByName(name);
    if (station == null || mapController == null) return;
    mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(station.position, 15),
    );
  }
}
