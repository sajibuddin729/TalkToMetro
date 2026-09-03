import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/data/metro_stations.dart';
import 'package:mrts/modules/fare_info/controller/fare_info_controller.dart';
import 'package:mrts/modules/fare_info/widget/fare_list.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class FareInfoScreen extends StatefulWidget {
  const FareInfoScreen({super.key});

  @override
  State<FareInfoScreen> createState() => _FareInfoScreenState();
}

class _FareInfoScreenState extends State<FareInfoScreen> {
  final controller = Get.put(FareInfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(
          "Fare Information",
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
            _FarePolicyCard(),
            _FareCalculatorWidget(controller: controller),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Full Station Fare Chart',
                  style: ubuntuBold.copyWith(fontSize: 16.sp, color: Colors.green.shade900),
                ),
              ),
            ),
            const FareInfoList(),
          ],
        ),
      ),
    );
  }
}

class _FarePolicyCard extends StatelessWidget {
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
              Icon(Icons.stars, color: Colors.green.shade800, size: 22.r),
              SizedBox(width: 8.w),
              Text(
                'DMTCL Official Fare Rules',
                style: ubuntuBold.copyWith(fontSize: 14.sp, color: Colors.green.shade900),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _PolicyItem(icon: Icons.payments, text: 'Minimum Fare: ৳ 20 | Maximum Fare: ৳ 100'),
          _PolicyItem(
              icon: Icons.credit_card, text: 'MRT Pass / Rapid Pass holders get 10% Discount'),
          _PolicyItem(
              icon: Icons.child_care, text: 'Children under 5 years travel free with an adult'),
          _PolicyItem(
              icon: Icons.confirmation_number,
              text: 'Single Journey Ticket (SJT) tokens valid for 1 day'),
        ],
      ),
    );
  }
}

class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PolicyItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: Colors.green.shade700),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: ubuntuMedium.copyWith(fontSize: 12.sp, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _FareCalculatorWidget extends StatelessWidget {
  final FareInfoController controller;
  const _FareCalculatorWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeDefault,
        0,
        Dimensions.paddingSizeDefault,
        Dimensions.paddingSizeDefault,
      ),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Fare Calculator',
            style: ubuntuBold.copyWith(fontSize: 14.sp, color: Colors.green.shade900),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            return DropdownButtonFormField<String>(
              isExpanded: true,
              value: controller.calcFromStation.value,
              decoration: InputDecoration(
                labelText: 'From Station',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                prefixIcon: Icon(Icons.subway, color: Colors.green.shade700, size: 20.r),
              ),
              items: metroStationNames.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  controller.calcFromStation.value = val;
                  controller.calculateFare();
                }
              },
            );
          }),
          SizedBox(height: 10.h),
          Obx(() {
            return DropdownButtonFormField<String>(
              isExpanded: true,
              value: controller.calcToStation.value,
              decoration: InputDecoration(
                labelText: 'To Station',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                prefixIcon: Icon(Icons.location_on, color: Colors.red.shade700, size: 20.r),
              ),
              items: metroStationNames.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  controller.calcToStation.value = val;
                  controller.calculateFare();
                }
              },
            );
          }),
          SizedBox(height: 14.h),
          Obx(() {
            return Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Single Journey',
                          style: ubuntuMedium.copyWith(fontSize: 11.sp, color: Colors.grey.shade700)),
                      SizedBox(height: 2.h),
                      Text('৳ ${controller.calculatedSingleFare.value}',
                          style: ubuntuBold.copyWith(fontSize: 18.sp, color: Colors.green.shade900)),
                    ],
                  ),
                  Container(height: 30.h, width: 1, color: Colors.green.shade200),
                  Column(
                    children: [
                      Text('MRT Pass (10% Off)',
                          style: ubuntuMedium.copyWith(fontSize: 11.sp, color: Colors.grey.shade700)),
                      SizedBox(height: 2.h),
                      Text('৳ ${controller.calculatedMrtFare.value}',
                          style: ubuntuBold.copyWith(fontSize: 18.sp, color: Colors.orange.shade900)),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
