import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mrts/data/metro_stations.dart';
import 'package:mrts/modules/live_tracker/controller/live_tracker_controller.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class LiveTrackerView extends StatelessWidget {
  const LiveTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveTrackerController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(
          "Live Metro Location",
          style: ubuntuBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Obx(() {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: dhakaMetroStations[8].position, // Agargaon (center of line)
                zoom: 12.5,
              ),
              markers: controller.markers.toSet(),
              polylines: controller.polylines.toSet(),
              onMapCreated: controller.onMapCreated,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
            );
          }),

          // Top Info Banner
          Positioned(
            top: 12.h,
            left: 14.w,
            right: 14.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Live Tracking Line 6 • Active Trains Moving',
                      style: ubuntuBold.copyWith(
                        fontSize: 12.sp,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                  Obx(() {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${controller.activeTrains.length} Active',
                        style: ubuntuBold.copyWith(
                          fontSize: 11.sp,
                          color: Colors.green.shade800,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Train Details Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Trains on Route',
                    style: ubuntuBold.copyWith(fontSize: 14.sp, color: Colors.black87),
                  ),
                  SizedBox(height: 10.h),

                  // Horizontal list of active trains
                  Obx(() {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.activeTrains.map((train) {
                          final isSelected = controller.selectedTrain.value?.id == train.id;
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: ChoiceChip(
                              label: Row(
                                children: [
                                  Icon(
                                    Icons.train,
                                    size: 16.r,
                                    color: isSelected ? Colors.white : Colors.green.shade700,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(train.id),
                                ],
                              ),
                              selected: isSelected,
                              selectedColor: Colors.green.shade700,
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: ubuntuBold.copyWith(
                                fontSize: 12.sp,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                              onSelected: (_) => controller.selectTrain(train),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),

                  SizedBox(height: 12.h),

                  // Selected Train Details Card
                  Obx(() {
                    final train = controller.selectedTrain.value;
                    if (train == null) return const SizedBox();

                    return Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                train.name,
                                style: ubuntuBold.copyWith(
                                  fontSize: 14.sp,
                                  color: Colors.green.shade900,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade700,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  '${train.speedKmh} km/h',
                                  style: ubuntuBold.copyWith(
                                    fontSize: 11.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Next Stop:',
                                style: ubuntuMedium.copyWith(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                '${train.nextStation} (in ${train.etaNextMin} min)',
                                style: ubuntuBold.copyWith(
                                  fontSize: 12.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status:',
                                style: ubuntuMedium.copyWith(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                train.status,
                                style: ubuntuBold.copyWith(
                                  fontSize: 12.sp,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          LinearProgressIndicator(
                            value: train.progress,
                            backgroundColor: Colors.green.shade100,
                            color: Colors.green.shade700,
                            minHeight: 6.h,
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
