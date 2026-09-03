import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/wallet/controller/wallet_controller.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class WalletList extends StatelessWidget {
  const WalletList({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WalletController>();

    return Padding(
      padding: EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Obx(() {
        if (controller.transactions.isEmpty) {
          return Center(
            child: Text(
              'No wallet transactions found.',
              style: ubuntuMedium.copyWith(fontSize: 13.sp, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            final tx = controller.transactions[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor:
                        tx.isCredit ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      tx.isCredit ? Icons.add_card : Icons.subway,
                      color: tx.isCredit ? Colors.green.shade800 : Colors.red.shade800,
                      size: 18.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.title,
                          style: ubuntuBold.copyWith(
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${tx.date} • ${tx.id}',
                          style: ubuntuRegular.copyWith(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${tx.isCredit ? '+' : '-'}৳${tx.amount.toStringAsFixed(0)}',
                    style: ubuntuBold.copyWith(
                      fontSize: 14.sp,
                      color: tx.isCredit ? Colors.green.shade800 : Colors.red.shade800,
                    ),
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
