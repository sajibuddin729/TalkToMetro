import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/common/custom_box.dart';
import 'package:mrts/modules/home/controller/home_controller.dart';
import 'package:mrts/routes/route_helper.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class MetroList extends StatelessWidget {
  const MetroList({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        controller.getData();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 18.h,
              childAspectRatio: 0.85,
            ),
            itemCount: controller.homecategory!.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        switch (index) {
                          case 0:
                            Get.toNamed(RouteHelper.getmyRouteScreen());
                            break;
                          case 1:
                            Get.toNamed(RouteHelper.getfareInfoScreen());
                            break;
                          case 2:
                            Get.toNamed(RouteHelper.gettimeTableScreen());
                            break;
                          case 3:
                            Get.toNamed(RouteHelper.getwalletScreen());
                            break;
                          case 4:
                            Get.toNamed(RouteHelper.getLiveTrackerScreen());
                            break;
                          case 5:
                            Get.toNamed(RouteHelper.getotherInfoScreen());
                            break;
                        }
                      },
                      child: CustomBox(
                        images: controller.homecategory![index].image!,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    controller.homecategory![index].name!,
                    style: ubuntuRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      fontWeight: FontWeight.normal,
                      color: const Color.fromARGB(255, 68, 69, 69),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
