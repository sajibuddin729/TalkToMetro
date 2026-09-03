import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mrts/modules/my_route/controller/map_route_controller.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class GoogleMapPageData extends StatelessWidget {
  const GoogleMapPageData({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MapRouteController());

    return Obx(() {
      if (c.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.green),
        );
      }

      return Column(
        children: [
          _StationSelectors(controller: c),
          if (c.errorMessage.value.isNotEmpty)
            Container(
              width: double.infinity,
              color: Colors.orange.shade50,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: Text(
                c.errorMessage.value,
                style: TextStyle(color: Colors.orange.shade900, fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: c.initialCamera,
                  onMapCreated: c.onMapCreated,
                  markers: c.markers.toSet(),
                  polylines: c.polylines.toSet(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                ),
                if (c.isRouting.value)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      color: Colors.green,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                Positioned(
                  right: 16.w,
                  bottom: 24.h,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'fit_route',
                        backgroundColor: Colors.white,
                        onPressed: c.fitRoute,
                        tooltip: 'Fit Route',
                        child: const Icon(Icons.crop_free, color: Colors.green),
                      ),
                      SizedBox(height: 10.h),
                      FloatingActionButton.small(
                        heroTag: 'my_location',
                        backgroundColor: Colors.green.shade700,
                        onPressed: c.useCurrentLocationAsStart,
                        tooltip: 'Route from My Location',
                        child: const Icon(Icons.my_location, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _StationSelectors extends StatelessWidget {
  const _StationSelectors({required this.controller});

  final MapRouteController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  label: 'From (Start)',
                  value: controller.fromStation.value,
                  items: controller.fromStationOptions(),
                  onChanged: controller.setFromStation,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: IconButton(
                  onPressed: controller.fromStation.value == MapRouteController.myLocationOption
                      ? null
                      : controller.swapStations,
                  icon: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: controller.fromStation.value == MapRouteController.myLocationOption
                          ? Colors.grey.shade200
                          : Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.swap_horiz,
                      color: controller.fromStation.value == MapRouteController.myLocationOption
                          ? Colors.grey
                          : Colors.green.shade700,
                      size: 22.r,
                    ),
                  ),
                  tooltip: 'Swap Stations',
                ),
              ),
              Expanded(
                child: _dropdown(
                  label: 'To (Destination)',
                  value: controller.toStation.value,
                  items: controller.toStationOptions(),
                  onChanged: controller.setToStation,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF3F1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoTile(
                  icon: Icons.subway,
                  label: 'Stops',
                  value: '${controller.stationCount}',
                ),
                Container(height: 24.h, width: 1, color: Colors.grey.shade300),
                _infoTile(
                  icon: Icons.timer_outlined,
                  label: 'Est. Time',
                  value: '${controller.estimatedTimeMinutes} min',
                ),
                Container(height: 24.h, width: 1, color: Colors.grey.shade300),
                _infoTile(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Est. Fare',
                  value: '৳${controller.estimatedFare}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final effectiveValue = items.contains(value) ? value : items.first;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: ubuntuRegular.copyWith(
          fontSize: 12.sp,
          color: Colors.green.shade800,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveValue,
          isDense: true,
          isExpanded: true,
          style: ubuntuMedium.copyWith(fontSize: 13.sp, color: Colors.black87),
          items: items
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s,
                    overflow: TextOverflow.ellipsis,
                    style: s == MapRouteController.myLocationOption
                        ? ubuntuBold.copyWith(fontSize: 13.sp, color: Colors.green.shade700)
                        : ubuntuMedium.copyWith(fontSize: 13.sp, color: Colors.black87),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 16.r, color: Colors.green.shade700),
            SizedBox(width: 4.w),
            Text(
              value,
              style: ubuntuBold.copyWith(
                fontSize: 14.sp,
                color: Colors.green.shade900,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: ubuntuRegular.copyWith(
            fontSize: 11.sp,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
