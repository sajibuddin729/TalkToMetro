import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mrts/data/metro_stations.dart';
import 'package:mrts/services/maps_service.dart';

class MapRouteController extends GetxController {
  final MapsService _mapsService = MapsService();
  final Location _location = Location();

  static const String myLocationOption = '📍 Current Location';

  final isLoading = false.obs;
  final isRouting = false.obs;
  final errorMessage = ''.obs;

  final fromStation = 'Uttara North'.obs;
  final toStation = 'Farmgate'.obs;

  LatLng? userPosition;
  GoogleMapController? mapController;

  final markers = <Marker>{}.obs;
  final polylines = <Polyline>{}.obs;

  static const LatLng _defaultCenter = LatLng(23.822350, 90.365417);

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    errorMessage.value = '';
    
    // Set initial markers and polyline instantly so the map renders immediately
    final from = metroStationByName(fromStation.value);
    final to = metroStationByName(toStation.value);
    if (from != null && to != null) {
      _buildMarkers(from.position, from.name, to.position, to.name);
      _buildPolylines([from.position, to.position]);
    }
    
    isLoading.value = false;

    // Prompt for location permission and use current location as start origin by default
    await _tryLoadUserLocation(forcePrompt: true);
    if (userPosition != null) {
      fromStation.value = myLocationOption;
    }
    await updateRoute();
  }

  Future<void> _tryLoadUserLocation({bool forcePrompt = false}) async {
    try {
      var serviceEnabled = await _location.serviceEnabled().timeout(const Duration(seconds: 2));
      if (!serviceEnabled) {
        if (forcePrompt) {
          serviceEnabled = await _location.requestService().timeout(const Duration(seconds: 4));
        }
        if (!serviceEnabled) return;
      }

      var permission = await _location.hasPermission().timeout(const Duration(seconds: 2));
      if (permission == PermissionStatus.denied) {
        if (forcePrompt) {
          permission = await _location.requestPermission().timeout(const Duration(seconds: 4));
        }
      }
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.grantedLimited) {
        return;
      }

      final loc = await _location.getLocation().timeout(const Duration(seconds: 4));
      if (loc.latitude != null && loc.longitude != null) {
        userPosition = LatLng(loc.latitude!, loc.longitude!);
      }
    } catch (_) {
      // Map works gracefully if location fails.
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    fitRoute();
  }

  void setFromStation(String? value) {
    if (value == null || value == toStation.value) return;
    fromStation.value = value;
    updateRoute();
  }

  void setToStation(String? value) {
    if (value == null || value == fromStation.value) return;
    toStation.value = value;
    updateRoute();
  }

  void swapStations() {
    if (fromStation.value == myLocationOption) return;
    final temp = fromStation.value;
    fromStation.value = toStation.value;
    toStation.value = temp;
    updateRoute();
  }

  Future<void> useCurrentLocationAsStart() async {
    isRouting.value = true;
    errorMessage.value = '';
    await _tryLoadUserLocation(forcePrompt: true);
    
    if (userPosition != null) {
      fromStation.value = myLocationOption;
      await updateRoute();
    } else {
      errorMessage.value =
          'Location permissions or GPS required to route from current position.';
    }
    isRouting.value = false;
  }

  Future<void> updateRoute() async {
    final to = metroStationByName(toStation.value);
    if (to == null) return;

    LatLng originPos;
    String originTitle;

    if (fromStation.value == myLocationOption) {
      if (userPosition == null) {
        await _tryLoadUserLocation(forcePrompt: true);
      }
      if (userPosition == null) {
        fromStation.value = 'Uttara North';
        await updateRoute();
        return;
      }
      originPos = userPosition!;
      originTitle = 'Current Location';
    } else {
      final from = metroStationByName(fromStation.value);
      if (from == null) return;
      originPos = from.position;
      originTitle = from.name;
    }

    isRouting.value = true;
    errorMessage.value = '';

    _buildMarkers(originPos, originTitle, to.position, to.name);

    try {
      final routePoints = await _mapsService.getDrivingRoute(
        origin: originPos,
        destination: to.position,
      );

      _buildPolylines(routePoints);
      await fitRoute();
    } catch (e) {
      _buildPolylines([originPos, to.position]);
    } finally {
      isRouting.value = false;
    }
  }

  void _buildMarkers(
    LatLng originPos,
    String originTitle,
    LatLng destPos,
    String destTitle,
  ) {
    final next = <Marker>{
      Marker(
        markerId: const MarkerId('from'),
        position: originPos,
        infoWindow: InfoWindow(title: 'Start', snippet: originTitle),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          originTitle == 'Current Location'
              ? BitmapDescriptor.hueAzure
              : BitmapDescriptor.hueGreen,
        ),
      ),
      Marker(
        markerId: const MarkerId('to'),
        position: destPos,
        infoWindow: InfoWindow(title: 'Destination', snippet: destTitle),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    if (userPosition != null && originTitle != 'Current Location') {
      next.add(
        Marker(
          markerId: const MarkerId('you'),
          position: userPosition!,
          infoWindow: const InfoWindow(
            title: 'You',
            snippet: 'Current location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }

    markers.assignAll(next);
  }

  void _buildPolylines(List<LatLng> points) {
    polylines.assignAll({
      Polyline(
        polylineId: const PolylineId('route'),
        color: const Color(0xFF2E7D32),
        width: 6,
        points: points,
      ),
      Polyline(
        polylineId: const PolylineId('metro_line'),
        color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
        width: 3,
        points: metroLineCoordinates,
      ),
    });
  }

  Future<void> fitRoute() async {
    if (mapController == null) return;

    LatLng originPos;
    if (fromStation.value == myLocationOption && userPosition != null) {
      originPos = userPosition!;
    } else {
      final from = metroStationByName(fromStation.value);
      originPos = from?.position ?? _defaultCenter;
    }

    final to = metroStationByName(toStation.value);
    if (to == null) return;

    final destPos = to.position;

    final southLat = originPos.latitude < destPos.latitude
        ? originPos.latitude
        : destPos.latitude;
    final northLat = originPos.latitude > destPos.latitude
        ? originPos.latitude
        : destPos.latitude;
    final westLng = originPos.longitude < destPos.longitude
        ? originPos.longitude
        : destPos.longitude;
    final eastLng = originPos.longitude > destPos.longitude
        ? originPos.longitude
        : destPos.longitude;

    final bounds = LatLngBounds(
      southwest: LatLng(southLat, westLng),
      northeast: LatLng(northLat, eastLng),
    );

    try {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 64),
      );
    } catch (_) {}
  }

  CameraPosition get initialCamera => CameraPosition(
        target: userPosition ?? _defaultCenter,
        zoom: 12,
      );

  List<String> toStationOptions() =>
      metroStationNames.where((n) => n != fromStation.value).toList();

  List<String> fromStationOptions() {
    final list = [myLocationOption, ...metroStationNames];
    return list.where((n) => n != toStation.value).toList();
  }

  MetroStation? get _nearestStationToUser {
    if (userPosition == null) return null;
    MetroStation? closest;
    double minDistance = double.infinity;

    for (final station in dhakaMetroStations) {
      final dLat = station.position.latitude - userPosition!.latitude;
      final dLng = station.position.longitude - userPosition!.longitude;
      final dist = (dLat * dLat) + (dLng * dLng);
      if (dist < minDistance) {
        minDistance = dist;
        closest = station;
      }
    }
    return closest;
  }

  int get stationCount {
    String fromName = fromStation.value;
    if (fromName == myLocationOption) {
      final nearest = _nearestStationToUser;
      if (nearest != null) {
        fromName = nearest.name;
      } else {
        fromName = 'Uttara North';
      }
    }
    final fromIndex = dhakaMetroStations.indexWhere((s) => s.name == fromName);
    final toIndex = dhakaMetroStations.indexWhere((s) => s.name == toStation.value);
    if (fromIndex == -1 || toIndex == -1) return 0;
    return (toIndex - fromIndex).abs();
  }

  int get estimatedFare {
    final count = stationCount;
    if (count == 0) return 0;
    if (count <= 2) return 20;
    int rawFare = 20 + ((count - 2) * 6);
    return ((rawFare / 10).ceil()) * 10;
  }

  int get estimatedTimeMinutes {
    final count = stationCount;
    if (count == 0) return 0;
    return (count * 3.5).round();
  }
}
