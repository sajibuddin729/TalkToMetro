import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/notification/controller/notification_controller.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(
          "Notifications",
          style: ubuntuBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: Icon(Icons.done_all, color: Colors.white, size: 22.r),
            onPressed: () => controller.markAllAsRead(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 64.r, color: Colors.grey),
                SizedBox(height: 12.h),
                Text(
                  'No notifications yet',
                  style: ubuntuBold.copyWith(fontSize: 16.sp, color: Colors.grey.shade700),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final item = controller.notifications[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: item.isRead ? Colors.white : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: item.isRead ? Colors.transparent : Colors.green.shade200,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: _getBgColor(item.type),
                    child: Icon(_getIcon(item.type), color: _getIconColor(item.type), size: 20.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: ubuntuBold.copyWith(
                                  fontSize: 13.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Text(
                              item.time,
                              style: ubuntuRegular.copyWith(
                                fontSize: 10.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item.message,
                          style: ubuntuRegular.copyWith(
                            fontSize: 12.sp,
                            color: Colors.grey.shade700,
                            height: 1.3,
                          ),
                        ),
                      ],
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

  IconData _getIcon(String type) {
    switch (type) {
      case 'recharge':
        return Icons.account_balance_wallet;
      case 'ticket':
        return Icons.confirmation_number;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  Color _getBgColor(String type) {
    switch (type) {
      case 'recharge':
        return Colors.green.shade100;
      case 'ticket':
        return Colors.blue.shade100;
      case 'schedule':
        return Colors.orange.shade100;
      default:
        return Colors.teal.shade100;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'recharge':
        return Colors.green.shade800;
      case 'ticket':
        return Colors.blue.shade800;
      case 'schedule':
        return Colors.orange.shade800;
      default:
        return Colors.teal.shade800;
    }
  }
}
