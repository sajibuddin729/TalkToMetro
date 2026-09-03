import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mrts/utils/dimensions.dart';

class CustomBox extends StatelessWidget {
  final String images;
  const CustomBox({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.gridItemSize,
      width: Dimensions.gridItemSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green, width: 2),
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      child: Center(
        child: Image.asset(images, scale: 2),
      ),
    );
  }
}
