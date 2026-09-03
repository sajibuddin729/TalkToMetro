import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/other_info/controller/other_info_controller.dart';
import 'package:mrts/modules/other_info/model/other_info_category_model.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class InfoList extends StatelessWidget {
  const InfoList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OtherInfoController>();

    return Obx(() {
      if (controller.filteredCategories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48.r, color: Colors.grey.shade400),
              SizedBox(height: 10.h),
              Text(
                'No information found matching search',
                style: ubuntuMedium.copyWith(
                    fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        itemCount: controller.filteredCategories.length,
        itemBuilder: (context, index) {
          final item = controller.filteredCategories[index];
          return _InfoCard(item: item, controller: controller);
        },
      );
    });
  }
}

class _InfoCard extends StatelessWidget {
  final OtherInfoCategory item;
  final OtherInfoController controller;

  const _InfoCard({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          leading: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(item.icon, color: Colors.green.shade800, size: 22.r),
          ),
          title: Text(
            item.title,
            style: ubuntuBold.copyWith(
              fontSize: 14.sp,
              color: Colors.green.shade900,
            ),
          ),
          subtitle: Text(
            item.subtitle,
            style: ubuntuRegular.copyWith(
              fontSize: 11.sp,
              color: Colors.grey.shade600,
            ),
          ),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1),
            SizedBox(height: 12.h),

            // Main Description
            Text(
              item.description,
              style: ubuntuMedium.copyWith(
                fontSize: 12.sp,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),

            if (item.bulletPoints != null && item.bulletPoints!.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.green.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Column(
                  children: item.bulletPoints!.map((bullet) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              size: 14.r, color: Colors.green.shade700),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              bullet,
                              style: ubuntuMedium.copyWith(
                                fontSize: 11.5.sp,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            if (item.actionLabel != null) ...[
              SizedBox(height: 14.h),
              ElevatedButton.icon(
                onPressed: () => controller.executeAction(item),
                icon: Icon(
                  item.actionType == 'tel' ? Icons.phone : Icons.arrow_forward,
                  size: 18.r,
                  color: Colors.white,
                ),
                label: Text(
                  item.actionLabel!,
                  style:
                      ubuntuBold.copyWith(fontSize: 12.sp, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  minimumSize: Size(double.infinity, 42.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
