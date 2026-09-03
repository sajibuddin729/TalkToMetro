import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mrts/data/metro_stations.dart';
import 'package:mrts/utils/style.dart';

/// In-App Navigation Screen
/// Shows the MRT metro line (fixed green polyline) + user's live location
/// + blue direction polyline from user → selected destination station.
class StationNavigationScreen extends StatefulWidget {
  final MetroStation destination;

  const StationNavigationScreen({super.key, required this.destination});

  @override
  State<StationNavigationScreen> createState() =>
      _StationNavigationScreenState();
}

class _StationNavigationScreenState extends State<StationNavigationScreen> {
  GoogleMapController? _mapController;
  final Location _location = Location();

  // Observables we manage locally
  LatLng? _userLatLng;
  StreamSubscription<LocationData>? _locationSub;

  // Map objects
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  bool _locationReady = false;
  String _statusText = 'Getting your location...';
  double? _distanceKm;

  @override
  void initState() {
    super.initState();
    _setupMetroLine();
    _setupDestinationMarker();
    _startLiveLocation();
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ── Metro line (green fixed polyline) ─────────────────────────
  void _setupMetroLine() {
    // All station markers (green)
    for (final s in dhakaMetroStations) {
      _markers.add(Marker(
        markerId: MarkerId('metro_${s.name}'),
        position: s.position,
        infoWindow: InfoWindow(title: s.name, snippet: 'MRT Line 6'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    // Green metro rail polyline
    _polylines.add(const Polyline(
      polylineId: PolylineId('metro_line'),
      color: Color(0xFF2E7D32),
      width: 4,
      points: [],
    ));

    // Assign real coordinates
    _polylines.removeWhere((p) => p.polylineId.value == 'metro_line');
    _polylines.add(Polyline(
      polylineId: const PolylineId('metro_line'),
      color: const Color(0xFF2E7D32),
      width: 4,
      points: metroLineCoordinates,
    ));
  }

  // ── Destination marker (red) ───────────────────────────────────
  void _setupDestinationMarker() {
    _markers.add(Marker(
      markerId: MarkerId('dest_${widget.destination.name}'),
      position: widget.destination.position,
      infoWindow: InfoWindow(
        title: widget.destination.name,
        snippet: 'Your Destination · MRT Line 6',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
  }

  // ── Live location stream ───────────────────────────────────────
  Future<void> _startLiveLocation() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        await _location.requestService();
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        await _location.requestPermission();
      }

      // 1. Get quick initial location fix
      await _location.changeSettings(accuracy: LocationAccuracy.balanced);
      LocationData? initialLoc;
      try {
        initialLoc = await _location.getLocation().timeout(
          const Duration(seconds: 3),
        );
      } catch (_) {}

      if (initialLoc != null && initialLoc.latitude != null && initialLoc.longitude != null) {
        _onLocationUpdate(LatLng(initialLoc.latitude!, initialLoc.longitude!));
      } else {
        // Initial fallback: Dhaka Center (Farmgate)
        _onLocationUpdate(const LatLng(23.7561, 90.3872));
      }

      // 2. High accuracy stream for live navigation
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 2000, // update every 2 seconds
        distanceFilter: 5, // update every 5 metres moved
      );

      _locationSub = _location.onLocationChanged.listen((data) {
        if (data.latitude == null || data.longitude == null) return;
        final userPos = LatLng(data.latitude!, data.longitude!);
        _onLocationUpdate(userPos);
      });
    } catch (_) {
      // Fallback if location service fails completely
      _onLocationUpdate(const LatLng(23.7561, 90.3872));
    }
  }

  void _onLocationUpdate(LatLng userPos) {
    if (!mounted) return;

    final dist = _haversineKm(
      userPos.latitude, userPos.longitude,
      widget.destination.position.latitude,
      widget.destination.position.longitude,
    );

    setState(() {
      _userLatLng = userPos;
      _locationReady = true;
      _distanceKm = dist;
      _statusText = dist < 0.05
          ? 'You have arrived! 🎉'
          : 'Navigate to ${widget.destination.name}';

      // Update user marker (blue dot override)
      _markers.removeWhere((m) => m.markerId.value == 'user_location');
      _markers.add(Marker(
        markerId: const MarkerId('user_location'),
        position: userPos,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));

      // Blue direction polyline: user → destination
      _polylines.removeWhere((p) => p.polylineId.value == 'direction_line');
      _polylines.add(Polyline(
        polylineId: const PolylineId('direction_line'),
        color: const Color(0xFF1565C0), // deep blue
        width: 5,
        points: [userPos, widget.destination.position],
        patterns: [PatternItem.dot, PatternItem.gap(12)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ));
    });

    // Animate camera to show both user + destination
    if (_mapController != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          userPos.latitude < widget.destination.position.latitude
              ? userPos.latitude
              : widget.destination.position.latitude,
          userPos.longitude < widget.destination.position.longitude
              ? userPos.longitude
              : widget.destination.position.longitude,
        ),
        northeast: LatLng(
          userPos.latitude > widget.destination.position.latitude
              ? userPos.latitude
              : widget.destination.position.latitude,
          userPos.longitude > widget.destination.position.longitude
              ? userPos.longitude
              : widget.destination.position.longitude,
        ),
      );
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 80),
      );
    }
  }

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = (dLat / 2) * (dLat / 2) +
        (dLon / 2) * (dLon / 2); // simplified
    return R * 2 * (a < 0 ? 0 : a > 1 ? 1 : a);
  }

  double _toRad(double d) => d * 3.14159265358979 / 180;

  String _formatDistance(double km) {
    if (km < 1.0) return '${(km * 1000).toStringAsFixed(0)} m away';
    return '${km.toStringAsFixed(2)} km away';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Google Map ─────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.destination.position,
              zoom: 13,
            ),
            onMapCreated: (ctrl) {
              _mapController = ctrl;
              // Once map is ready, if we already have user location, animate
              if (_userLatLng != null) _onLocationUpdate(_userLatLng!);
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            trafficEnabled: false,
          ),

          // ── Top Header Bar ─────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_back_ios_new,
                            size: 16.r, color: Colors.green.shade800),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Navigating to',
                            style: ubuntuRegular.copyWith(
                                fontSize: 11.sp, color: Colors.grey.shade500),
                          ),
                          Text(
                            widget.destination.name,
                            style: ubuntuBold.copyWith(
                                fontSize: 15.sp, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'MRT Line 6 · Dhaka Metro',
                            style: ubuntuRegular.copyWith(
                                fontSize: 10.sp, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    // Distance badge
                    if (_distanceKm != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: _distanceKm! < 0.05
                              ? Colors.green.shade700
                              : const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          _formatDistance(_distanceKm!),
                          style: ubuntuBold.copyWith(
                              fontSize: 11.sp, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ── Loading overlay ────────────────────────────────────
          if (!_locationReady)
            Positioned(
              bottom: 120.h,
              left: 16.w,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18.r,
                      height: 18.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10.w),
                    Text(_statusText,
                        style: ubuntuRegular.copyWith(fontSize: 13.sp)),
                  ],
                ),
              ),
            ),

          // ── Bottom Legend Panel ────────────────────────────────
          if (_locationReady)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.r),
                    topRight: Radius.circular(20.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        // Legend: Metro Line
                        _LegendItem(
                          color: const Color(0xFF2E7D32),
                          label: 'MRT Line 6',
                          isDashed: false,
                        ),
                        SizedBox(width: 16.w),
                        // Legend: Direction
                        _LegendItem(
                          color: const Color(0xFF1565C0),
                          label: 'Your Route',
                          isDashed: true,
                        ),
                        SizedBox(width: 16.w),
                        // Legend: User location
                        Row(
                          children: [
                            Container(
                              width: 12.r,
                              height: 12.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2196F3),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text('You',
                                style: ubuntuRegular.copyWith(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade700)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    // Destination row
                    Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.train_outlined,
                              color: Colors.green.shade700, size: 20.r),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.destination.name,
                                  style: ubuntuBold.copyWith(
                                      fontSize: 13.sp,
                                      color: Colors.green.shade900),
                                ),
                                Text(
                                  _distanceKm != null
                                      ? _formatDistance(_distanceKm!)
                                      : 'Calculating...',
                                  style: ubuntuRegular.copyWith(
                                      fontSize: 11.sp,
                                      color: Colors.green.shade700),
                                ),
                              ],
                            ),
                          ),
                          if (_distanceKm != null && _distanceKm! < 0.05)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: Colors.green.shade700,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Arrived! 🎉',
                                style: ubuntuBold.copyWith(
                                    fontSize: 11.sp, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Re-center button ───────────────────────────────────
          if (_locationReady)
            Positioned(
              right: 16.w,
              bottom: 160.h,
              child: GestureDetector(
                onTap: () {
                  if (_userLatLng != null) _onLocationUpdate(_userLatLng!);
                },
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.my_location,
                      color: Colors.green.shade700, size: 22.r),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDashed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24.w,
          child: isDashed
              ? Row(
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 5.w,
                      height: 3.h,
                      margin: EdgeInsets.only(right: 2.w),
                      color: color,
                    ),
                  ),
                )
              : Container(height: 3.h, color: color),
        ),
        SizedBox(width: 4.w),
        Text(label,
            style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
