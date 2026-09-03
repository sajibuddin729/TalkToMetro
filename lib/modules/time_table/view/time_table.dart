import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/data/metro_stations.dart';
import 'package:mrts/modules/time_table/controller/time_table_controller.dart';
import 'package:mrts/modules/time_table/widget/table_list.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class TimeTableScreen extends StatefulWidget {
  const TimeTableScreen({super.key});

  @override
  State<TimeTableScreen> createState() => _TimeTableScreenState();
}

class _TimeTableScreenState extends State<TimeTableScreen> {
  final TimeTableController controller = Get.put(TimeTableController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(
          "Time Table & Schedule",
          style: ubuntuBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _OperatingHoursCard(),
            _StationSelectorCard(controller: controller),
            _TimeSlotFilterCard(controller: controller),
            const TableList(),
          ],
        ),
      ),
    );
  }
}

class _OperatingHoursCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.green.shade800, size: 22.r),
              SizedBox(width: 8.w),
              Text(
                'Metro Line 6 Operating Schedule',
                style: ubuntuBold.copyWith(fontSize: 14.sp, color: Colors.green.shade900),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _ScheduleRow(title: 'Weekdays (Sun–Thu):', detail: '06:30 AM – 10:10 PM'),
          _ScheduleRow(title: 'Friday Service:', detail: '03:00 PM – 09:40 PM'),
          _ScheduleRow(title: 'Saturday Service:', detail: '06:30 AM – 09:40 PM'),
          SizedBox(height: 6.h),
          Divider(color: Colors.grey.shade200),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _FreqBadge(label: 'Peak: ~6 min'),
              _FreqBadge(label: 'Off-Peak: ~8 min'),
              _FreqBadge(label: 'Night: ~12 min'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String title;
  final String detail;
  const _ScheduleRow({required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: ubuntuMedium.copyWith(fontSize: 12.sp, color: Colors.grey.shade700)),
          Text(detail, style: ubuntuBold.copyWith(fontSize: 12.sp, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _FreqBadge extends StatelessWidget {
  final String label;
  const _FreqBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        label,
        style: ubuntuMedium.copyWith(fontSize: 11.sp, color: Colors.green.shade800),
      ),
    );
  }
}

class _StationSelectorCard extends StatelessWidget {
  final TimeTableController controller;
  const _StationSelectorCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Route Timings',
                style: ubuntuBold.copyWith(fontSize: 14.sp, color: Colors.black87),
              ),
              IconButton(
                onPressed: () => controller.swapStations(),
                icon: Icon(Icons.swap_horiz, color: Colors.green.shade700, size: 24.r),
                tooltip: 'Swap stations',
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: controller.selectedOrigin.value,
                    decoration: InputDecoration(
                      labelText: 'From Station',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    items: metroStationNames.map((station) {
                      return DropdownMenuItem(
                        value: station,
                        child: Text(
                          station,
                          style: ubuntuMedium.copyWith(fontSize: 12.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedOrigin.value = val;
                        controller.generateSchedule();
                      }
                    },
                  );
                }),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Obx(() {
                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: controller.selectedDestination.value,
                    decoration: InputDecoration(
                      labelText: 'To Station',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    items: metroStationNames.map((station) {
                      return DropdownMenuItem(
                        value: station,
                        child: Text(
                          station,
                          style: ubuntuMedium.copyWith(fontSize: 12.sp),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedDestination.value = val;
                        controller.generateSchedule();
                      }
                    },
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeSlotFilterCard extends StatelessWidget {
  final TimeTableController controller;
  const _TimeSlotFilterCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final slots = ['All Day', 'Morning', 'Afternoon', 'Evening'];

    return Container(
      margin: EdgeInsets.all(Dimensions.paddingSizeDefault),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Departure Time',
                style: ubuntuBold.copyWith(fontSize: 13.sp, color: Colors.grey.shade800),
              ),
              Obx(() {
                return Text(
                  '${controller.filteredSchedule.length} Trains Found',
                  style: ubuntuBold.copyWith(fontSize: 12.sp, color: Colors.green.shade800),
                );
              }),
            ],
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: slots.map((slot) {
                return Obx(() {
                  final isSelected = controller.selectedSlot.value == slot;
                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: ChoiceChip(
                      label: Text(slot),
                      selected: isSelected,
                      selectedColor: Colors.green.shade700,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: ubuntuBold.copyWith(
                        fontSize: 12.sp,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      onSelected: (_) {
                        controller.selectedSlot.value = slot;
                        controller.applyFilter();
                      },
                    ),
                  );
                });
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
