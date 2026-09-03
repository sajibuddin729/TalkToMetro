import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/fare_info/controller/fare_info_controller.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class FareInfoList extends StatelessWidget {
  const FareInfoList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FareInfoController>(
      initState: (init) {
        Get.find<FareInfoController>().getData();
      },
      builder: (controller) {
        if (controller.farecategory == null || controller.farecategory!.isEmpty) {
          return const SizedBox();
        }

        return Padding(
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade200, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(2.5), // From Station
                1: FlexColumnWidth(0.6), // Arrow
                2: FlexColumnWidth(2.5), // To Station
                3: FlexColumnWidth(1.2), // Standard Fare
                4: FlexColumnWidth(1.2), // MRT Pass Fare
              },
              children: [
                // Header Row
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                  ),
                  children: [
                    _headerCell('From'),
                    _headerCell(''),
                    _headerCell('To'),
                    _headerCell('Standard'),
                    _headerCell('MRT Pass'),
                  ],
                ),
                // Data Rows
                for (var fare in controller.farecategory!)
                  TableRow(
                    children: [
                      _dataCell(fare.start ?? '', isBold: true),
                      _dataCell('➔', color: Colors.green.shade700),
                      _dataCell(fare.des ?? '', isBold: true),
                      _dataCell(fare.taka ?? '', color: Colors.green.shade900),
                      _dataCell(fare.mrtPassFare ?? '', color: Colors.orange.shade900),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headerCell(String text) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: ubuntuBold.copyWith(
            fontSize: 11.sp,
            color: Colors.green.shade900,
          ),
        ),
      ),
    );
  }

  Widget _dataCell(String text, {bool isBold = false, Color? color}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: (isBold ? ubuntuBold : ubuntuMedium).copyWith(
            fontSize: 11.sp,
            color: color ?? Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
