import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/ticket/tics.dart';
import 'package:mrts/utils/style.dart';

/// Simplified Top Section — only a "Search Train" button.
/// Dropdowns removed per user request.
class TopSections extends StatelessWidget {
  const TopSections({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ElevatedButton.icon(
        onPressed: () => Get.to(() => const TrainTicketSearch()),
        icon: const Icon(Icons.search, color: Colors.white),
        label: Text(
          'Search Train',
          style: ubuntuBold.copyWith(
            color: Colors.white,
            fontSize: 17.sp,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4D9D47),
          minimumSize: Size(double.infinity, 52.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
