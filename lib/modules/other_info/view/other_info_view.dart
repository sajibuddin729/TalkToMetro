import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/other_info/controller/other_info_controller.dart';
import 'package:mrts/modules/other_info/widget/info_list.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class OtherInfoScreen extends StatelessWidget {
  const OtherInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OtherInfoController());

    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(
          "Other Information & Guide",
          style: ubuntuBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  onChanged: (val) => controller.filterSearch(val),
                  decoration: InputDecoration(
                    hintText: 'Search schedule, rules, helpline, lost & found...',
                    hintStyle: ubuntuRegular.copyWith(fontSize: 12.sp, color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.green.shade700, size: 22.r),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    filled: true,
                    fillColor: const Color(0xFFEBF3F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(() {
                    return Row(
                      children: controller.categoriesList.map((cat) {
                        final isSelected = controller.selectedCategory.value == cat;
                        return Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: Colors.green.shade700,
                            backgroundColor: Colors.grey.shade100,
                            labelStyle: ubuntuBold.copyWith(
                              fontSize: 11.sp,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            onSelected: (_) => controller.selectCategory(cat),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Main Info Cards List
          const Expanded(
            child: InfoList(),
          ),
        ],
      ),
    );
  }
}
