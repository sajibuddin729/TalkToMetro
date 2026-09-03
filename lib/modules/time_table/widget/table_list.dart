import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/time_table/controller/time_table_controller.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class TableList extends StatelessWidget {
  const TableList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TimeTableController>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Obx(() {
        if (controller.filteredSchedule.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30.h),
              child: Column(
                children: [
                  Icon(Icons.directions_subway_sharp, size: 48.r, color: Colors.grey),
                  SizedBox(height: 8.h),
                  Text(
                    'No trains scheduled for selected filter.',
                    style: ubuntuMedium.copyWith(fontSize: 13.sp, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.filteredSchedule.length,
          itemBuilder: (context, index) {
            final item = controller.filteredSchedule[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.train, size: 20.r, color: Colors.green.shade700),
                          SizedBox(width: 6.w),
                          Text(
                            item.trainNo,
                            style: ubuntuBold.copyWith(
                              fontSize: 13.sp,
                              color: Colors.green.shade900,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              item.direction,
                              style: ubuntuMedium.copyWith(fontSize: 10.sp, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: item.taka.contains('Peak') ? Colors.orange.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          item.taka,
                          style: ubuntuBold.copyWith(
                            fontSize: 11.sp,
                            color: item.taka.contains('Peak') ? Colors.orange.shade900 : Colors.green.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          item.start,
                          style: ubuntuBold.copyWith(
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            children: [
                              Text(
                                '${item.totalDurationMin} min trip',
                                style: ubuntuRegular.copyWith(fontSize: 10.sp, color: Colors.grey.shade600),
                              ),
                              Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                  Icon(Icons.east, size: 14.r, color: Colors.green.shade700),
                                  Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          item.des,
                          textAlign: TextAlign.end,
                          style: ubuntuBold.copyWith(
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dep: ${item.time}',
                        style: ubuntuBold.copyWith(
                          fontSize: 12.sp,
                          color: Colors.green.shade900,
                        ),
                      ),
                      Text(
                        'Arr: ${item.destime}',
                        style: ubuntuMedium.copyWith(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
