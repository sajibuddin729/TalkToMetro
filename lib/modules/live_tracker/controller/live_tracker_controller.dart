import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mrts/data/metro_stations.dart';

class LiveMetroTrain {
  final String id;
  final String name;
  final String direction; // 'Southbound' or 'Northbound'
  int currentStationIndex;
  double progress; // 0.0 to 1.0 between currentStationIndex and next
  int speedKmh;
  String status;
  String nextStation;
  int etaNextMin;
  LatLng currentPosition;

  LiveMetroTrain({
    required this.id,
    required this.name,
    required this.direction,
    required this.currentStationIndex,
    required this.progress,
    required this.speedKmh,
    required this.status,
    required this.nextStation,
    required this.etaNextMin,
    required this.currentPosition,
  });
}

class LiveTrackerController extends GetxController implements GetxService {
  GoogleMapController? mapController;
  Timer? _timer;

  final activeTrains = <LiveMetroTrain>[].obs;
  final selectedTrain = Rxn<LiveMetroTrain>();

  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initRoutePolyline();
    _initActiveTrains();
    _startLiveSimulation();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void selectTrain(LiveMetroTrain train) {
    selectedTrain.value = train;
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(train.currentPosition, 15.0),
    );
  }

  void _initRoutePolyline() {
    polylines.add(
      Polyline(
        polylineId: const PolylineId('metro_line_6'),
        points: metroLineCoordinates,
        color: Colors.green.shade700,
        width: 5,
      ),
    );

    // Add station markers
    final stationMarkers = <Marker>{};
    for (int i = 0; i < dhakaMetroStations.length; i++) {
      final station = dhakaMetroStations[i];
      stationMarkers.add(
        Marker(
          markerId: MarkerId('station_$i'),
          position: station.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: station.name,
            snippet: 'Metro Line 6 Station',
          ),
        ),
      );
    }
    markers.addAll(stationMarkers);
  }

  void _initActiveTrains() {
    final stations = dhakaMetroStations;

    activeTrains.assignAll([
      LiveMetroTrain(
        id: 'MRT-102',
        name: 'Train #102 (Southbound)',
        direction: 'Southbound',
        currentStationIndex: 2, // Uttara South -> Pallabi
        progress: 0.4,
        speedKmh: 58,
        status: 'In Transit',
        nextStation: stations[3].name,
        etaNextMin: 2,
        currentPosition: _interpolate(stations[2].position, stations[3].position, 0.4),
      ),
      LiveMetroTrain(
        id: 'MRT-106',
        name: 'Train #106 (Southbound)',
        direction: 'Southbound',
        currentStationIndex: 6, // Kazipara -> Shewrapara
        progress: 0.7,
        speedKmh: 52,
        status: 'Approaching Station',
        nextStation: stations[7].name,
        etaNextMin: 1,
        currentPosition: _interpolate(stations[6].position, stations[7].position, 0.7),
      ),
      LiveMetroTrain(
        id: 'MRT-110',
        name: 'Train #110 (Southbound)',
        direction: 'Southbound',
        currentStationIndex: 10, // Farmgate -> Karwan Bazar
        progress: 0.2,
        speedKmh: 45,
        status: 'In Transit',
        nextStation: stations[11].name,
        etaNextMin: 3,
        currentPosition: _interpolate(stations[10].position, stations[11].position, 0.2),
      ),
      LiveMetroTrain(
        id: 'MRT-201',
        name: 'Train #201 (Northbound)',
        direction: 'Northbound',
        currentStationIndex: 14, // Secretariat -> DU (heading north)
        progress: 0.5,
        speedKmh: 56,
        status: 'In Transit',
        nextStation: stations[13].name,
        etaNextMin: 2,
        currentPosition: _interpolate(stations[14].position, stations[13].position, 0.5),
      ),
      LiveMetroTrain(
        id: 'MRT-205',
        name: 'Train #205 (Northbound)',
        direction: 'Northbound',
        currentStationIndex: 8, // Agargaon -> Shewrapara (heading north)
        progress: 0.8,
        speedKmh: 35,
        status: 'Boarding Passengers',
        nextStation: stations[7].name,
        etaNextMin: 1,
        currentPosition: _interpolate(stations[8].position, stations[7].position, 0.8),
      ),
    ]);

    selectedTrain.value = activeTrains.first;
    _updateTrainMarkers();
  }

  void _startLiveSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      final stations = dhakaMetroStations;

      for (var train in activeTrains) {
        train.progress += 0.08;

        if (train.progress >= 1.0) {
          train.progress = 0.0;
          if (train.direction == 'Southbound') {
            if (train.currentStationIndex < stations.length - 2) {
              train.currentStationIndex++;
            } else {
              train.currentStationIndex = 0; // Loop back
            }
            final nextIdx = train.currentStationIndex + 1;
            train.nextStation = stations[nextIdx].name;
          } else {
            if (train.currentStationIndex > 1) {
              train.currentStationIndex--;
            } else {
              train.currentStationIndex = stations.length - 1; // Loop back
            }
            final nextIdx = train.currentStationIndex - 1;
            train.nextStation = stations[nextIdx].name;
          }
        }

        final targetIdx = train.direction == 'Southbound'
            ? train.currentStationIndex + 1
            : train.currentStationIndex - 1;

        train.currentPosition = _interpolate(
          stations[train.currentStationIndex].position,
          stations[targetIdx].position,
          train.progress,
        );

        if (train.progress > 0.85) {
          train.status = 'Approaching Station';
          train.etaNextMin = 1;
          train.speedKmh = 30;
        } else if (train.progress < 0.15) {
          train.status = 'Boarding Passengers';
          train.etaNextMin = 0;
          train.speedKmh = 0;
        } else {
          train.status = 'In Transit (On Time)';
          train.etaNextMin = (2 * (1.0 - train.progress)).ceil();
          train.speedKmh = 55;
        }
      }

      activeTrains.refresh();
      _updateTrainMarkers();
    });
  }

  void _updateTrainMarkers() {
    final updatedMarkers = <Marker>{};

    // Keep station markers
    for (int i = 0; i < dhakaMetroStations.length; i++) {
      final station = dhakaMetroStations[i];
      updatedMarkers.add(
        Marker(
          markerId: MarkerId('station_$i'),
          position: station.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: station.name,
            snippet: 'Metro Line 6 Station',
          ),
        ),
      );
    }

    // Add live train markers
    for (var train in activeTrains) {
      updatedMarkers.add(
        Marker(
          markerId: MarkerId('train_${train.id}'),
          position: train.currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            train.direction == 'Southbound' ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: '${train.id} • ${train.direction}',
            snippet: 'Next: ${train.nextStation} (${train.etaNextMin} min)',
          ),
          onTap: () => selectTrain(train),
        ),
      );
    }

    markers.assignAll(updatedMarkers);
  }

  LatLng _interpolate(LatLng from, LatLng to, double t) {
    final lat = from.latitude + (to.latitude - from.latitude) * t;
    final lng = from.longitude + (to.longitude - from.longitude) * t;
    return LatLng(lat, lng);
  }
}
