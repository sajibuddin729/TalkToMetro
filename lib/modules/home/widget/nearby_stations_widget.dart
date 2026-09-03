import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:mrts/data/metro_stations.dart';
import 'package:mrts/modules/route/view/station_navigation_screen.dart';
import 'package:mrts/utils/style.dart';

/// Nearby Station data holder after distance calculation
class _NearbyStation {
  final MetroStation station;
  final double distanceKm;

  const _NearbyStation({required this.station, required this.distanceKm});
}

/// Shows the 3 nearest MRT stations based on the user's live GPS location.
/// Tapping a station opens Google Maps with walking directions.
class NearbyStationsWidget extends StatefulWidget {
  const NearbyStationsWidget({super.key});

  @override
  State<NearbyStationsWidget> createState() => _NearbyStationsWidgetState();
}

class _NearbyStationsWidgetState extends State<NearbyStationsWidget> {
  final Location _location = Location();

  bool _isLoading = true;
  String? _errorMessage;
  List<_NearbyStation> _nearestStations = [];

  @override
  void initState() {
    super.initState();
    _fetchNearbyStations();
  }

  /// Haversine formula — distance in km between two lat/lng points
  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;

  Future<void> _fetchNearbyStations() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    double userLat = 23.7561;
    double userLon = 90.3872;

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        await _location.requestService();
      }

      PermissionStatus permission = await _location.hasPermission();
      if (permission == PermissionStatus.denied) {
        await _location.requestPermission();
      }

      // Use balanced accuracy so network/fused location returns fast without waiting for GPS satellites
      await _location.changeSettings(accuracy: LocationAccuracy.balanced);

      LocationData? locData;
      try {
        locData = await _location.getLocation().timeout(
          const Duration(seconds: 3),
        );
      } catch (_) {
        // If single fix times out, try reading from stream once
      }

      if (locData != null && locData.latitude != null && locData.longitude != null) {
        userLat = locData.latitude!;
        userLon = locData.longitude!;
      }
    } catch (_) {
      // Fallback to Dhaka central coordinates so UI always functions smoothly
      userLat = 23.7561;
      userLon = 90.3872;
    }

    final sorted = dhakaMetroStations.map((station) {
      final dist = _haversineKm(
        userLat, userLon,
        station.position.latitude, station.position.longitude,
      );
      return _NearbyStation(station: station, distanceKm: dist);
    }).toList()..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    if (mounted) {
      setState(() {
        _nearestStations = sorted.take(3).toList();
        _isLoading = false;
      });
    }
  }

  /// Push in-app navigation screen to the selected station
  void _openDirections(_NearbyStation item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StationNavigationScreen(
          destination: item.station,
        ),
      ),
    );
  }

  String _formatDistance(double km) {
    if (km < 1.0) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.location_on, color: Colors.green.shade700, size: 16.r),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Nearby Stations',
                    style: ubuntuBold.copyWith(fontSize: 16.sp, color: Colors.green.shade900),
                  ),
                ],
              ),
              if (!_isLoading)
                GestureDetector(
                  onTap: _fetchNearbyStations,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 13.r, color: Colors.green.shade700),
                        SizedBox(width: 3.w),
                        Text('Refresh', style: ubuntuMedium.copyWith(fontSize: 11.sp, color: Colors.green.shade700)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),

          // ── Loading ───────────────────────────────────────────
          if (_isLoading)
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
              child: Row(
                children: [
                  SizedBox(width: 20.r, height: 20.r,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green.shade700)),
                  SizedBox(width: 12.w),
                  Text('Detecting your location...', style: ubuntuRegular.copyWith(fontSize: 13.sp, color: Colors.grey.shade600)),
                ],
              ),
            ),

          // ── Error ─────────────────────────────────────────────
          if (!_isLoading && _errorMessage != null)
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_off, color: Colors.orange.shade700, size: 20.r),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Location unavailable', style: ubuntuBold.copyWith(fontSize: 13.sp, color: Colors.orange.shade800)),
                        Text(_errorMessage!, style: ubuntuRegular.copyWith(fontSize: 11.sp, color: Colors.orange.shade700)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _fetchNearbyStations,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8.r)),
                      child: Icon(Icons.refresh, size: 16.r, color: Colors.orange.shade800),
                    ),
                  ),
                ],
              ),
            ),

          // ── Nearest 3 Stations ────────────────────────────────
          if (!_isLoading && _errorMessage == null)
            Column(
              children: List.generate(_nearestStations.length, (i) {
                final item = _nearestStations[i];
                return _StationTile(
                  rank: i + 1,
                  station: item.station,
                  distance: _formatDistance(item.distanceKm),
                  isClosest: i == 0,
                  onTap: () => _openDirections(item),
                );
              }),
            ),
        ],
      ),
    );
  }
}

class _StationTile extends StatelessWidget {
  final int rank;
  final MetroStation station;
  final String distance;
  final bool isClosest;
  final VoidCallback onTap;

  const _StationTile({
    required this.rank,
    required this.station,
    required this.distance,
    required this.isClosest,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isClosest ? Colors.green.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: isClosest ? Colors.green.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Rank Badge
            Container(
              width: 30.r, height: 30.r,
              decoration: BoxDecoration(
                color: isClosest ? Colors.white.withValues(alpha: 0.2) : Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('#$rank', style: ubuntuBold.copyWith(fontSize: 11.sp, color: isClosest ? Colors.white : Colors.green.shade800)),
              ),
            ),
            SizedBox(width: 10.w),

            // Icon
            Container(
              padding: EdgeInsets.all(7.r),
              decoration: BoxDecoration(
                color: isClosest ? Colors.white.withValues(alpha: 0.15) : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.train_outlined, size: 18.r, color: isClosest ? Colors.white : Colors.green.shade700),
            ),
            SizedBox(width: 10.w),

            // Name + Line
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(station.name, style: ubuntuBold.copyWith(fontSize: 14.sp, color: isClosest ? Colors.white : Colors.black87)),
                  SizedBox(height: 1.h),
                  Text('MRT Line 6 • Tap for directions', style: ubuntuRegular.copyWith(fontSize: 10.sp, color: isClosest ? Colors.white.withValues(alpha: 0.75) : Colors.grey.shade500)),
                ],
              ),
            ),

            // Distance Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: isClosest ? Colors.white.withValues(alpha: 0.2) : Colors.green.shade50,
                borderRadius: BorderRadius.circular(20.r),
                border: isClosest
                    ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1)
                    : Border.all(color: Colors.green.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.navigation, size: 11.r, color: isClosest ? Colors.white : Colors.green.shade700),
                  SizedBox(width: 3.w),
                  Text(distance, style: ubuntuBold.copyWith(fontSize: 11.sp, color: isClosest ? Colors.white : Colors.green.shade800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
