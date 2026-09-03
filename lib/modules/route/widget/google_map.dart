import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mrts/data/metro_stations.dart';
import 'package:mrts/modules/route/controller/metro_map_controller.dart';
import 'package:mrts/utils/dimensions.dart';

class GoogleMapScreen extends StatelessWidget {
  const GoogleMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MetroMapController());

    return Column(
      children: [
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            itemCount: dhakaMetroStations.length,
            itemBuilder: (context, index) {
              final station = dhakaMetroStations[index];
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ActionChip(
                  label: Text(
                    station.name,
                    style: TextStyle(fontSize: 11.sp),
                  ),
                  onPressed: () => c.focusStation(station.name),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: Obx(
            () => GoogleMap(
              initialCameraPosition: MetroMapController.initialCamera,
              onMapCreated: c.onMapCreated,
              markers: c.markers.toSet(),
              polylines: c.polylines.toSet(),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
            ),
          ),
        ),
      ],
    );
  }
}
