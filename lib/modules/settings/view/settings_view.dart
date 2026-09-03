import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mrts/modules/settings/controller/settings_controller.dart';
import 'package:mrts/modules/travel_log/controller/travel_log_controller.dart';
import 'package:mrts/modules/travel_log/view/travel_log_view.dart';
import 'package:mrts/modules/settings/view/edit_profile_view.dart';
import 'package:mrts/modules/settings/view/help_center_view.dart';
import 'package:mrts/modules/settings/view/mrt_pass_view.dart';
import 'package:mrts/modules/settings/view/privacy_policy_view.dart';
import 'package:mrts/modules/wallet/controller/wallet_controller.dart';
import 'package:mrts/services/auth_service.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: ubuntuBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            _ProfileHeaderCard(controller: c),
            SizedBox(height: 16.h),
            _MrtPassSummaryCard(controller: c),
            SizedBox(height: 16.h),
            _TravelLogSummaryCard(),
            SizedBox(height: 20.h),
            _SectionHeader(title: 'Preferences'),
            SizedBox(height: 8.h),
            _PreferencesCard(controller: c),
            SizedBox(height: 20.h),
            _SectionHeader(title: 'Support & Info'),
            SizedBox(height: 8.h),
            _SupportCard(),
            SizedBox(height: 24.h),
            _LogoutButton(),
            SizedBox(height: 8.h),
            Text(
              'Dhaka Metro Rail v1.0.0',
              style: ubuntuRegular.copyWith(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: ubuntuBold.copyWith(
          fontSize: 15.sp,
          color: Colors.green.shade900,
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.controller});
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade800, Colors.green.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.to(() => const EditProfileView()),
              child: CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: controller.profileImagePath.value.isNotEmpty
                    ? FileImage(File(controller.profileImagePath.value))
                    : null,
                child: controller.profileImagePath.value.isEmpty
                    ? Icon(Icons.person, size: 30.r, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userName.value,
                    style: ubuntuBold.copyWith(
                      fontSize: 17.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    controller.userPhone.value,
                    style: ubuntuRegular.copyWith(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  Text(
                    controller.userEmail.value,
                    style: ubuntuRegular.copyWith(
                      fontSize: 11.sp,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Get.to(() => const EditProfileView()),
              icon: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, size: 16.r, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MrtPassSummaryCard extends StatelessWidget {
  const _MrtPassSummaryCard({required this.controller});
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.credit_card, color: Colors.white, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    'MRT / Rapid Pass',
                    style: ubuntuBold.copyWith(
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Active',
                  style: ubuntuMedium.copyWith(
                    fontSize: 11.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            'Available Balance',
            style: ubuntuRegular.copyWith(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                final walletCtrl = Get.isRegistered<WalletController>()
                    ? Get.find<WalletController>()
                    : Get.put(WalletController());
                return Text(
                  '৳ ${walletCtrl.walletBalance.value.toStringAsFixed(2)}',
                  style: ubuntuBold.copyWith(
                    fontSize: 24.sp,
                    color: Colors.white,
                  ),
                );
              }),
              ElevatedButton.icon(
                onPressed: () => Get.to(() => const MrtPassView()),
                icon:
                    Icon(Icons.add, size: 16.r, color: Colors.green.shade800),
                label: Text(
                  'Recharge',
                  style: ubuntuBold.copyWith(
                    fontSize: 12.sp,
                    color: Colors.green.shade800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Travel Log Quick Summary Card — shown on Settings screen
class _TravelLogSummaryCard extends StatelessWidget {
  const _TravelLogSummaryCard();

  @override
  Widget build(BuildContext context) {
    final logCtrl = Get.isRegistered<TravelLogController>()
        ? Get.find<TravelLogController>()
        : Get.put(TravelLogController());

    return GestureDetector(
      onTap: () => Get.to(() => const TravelLogView()),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF3FF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.directions_railway_outlined,
                  color: const Color(0xFF0052FF), size: 24.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel Log',
                    style: ubuntuBold.copyWith(
                        fontSize: 14.sp, color: Colors.black87),
                  ),
                  SizedBox(height: 2.h),
                  Obx(() => Text(
                        '${logCtrl.totalTripsCount} trips recorded · ৳${logCtrl.thisMonthSpending.toStringAsFixed(0)} this month',
                        style: ubuntuRegular.copyWith(
                            fontSize: 11.sp, color: Colors.grey.shade600),
                      )),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20.r),
          ],
        ),
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({required this.controller});
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Obx(() {
        return Column(
          children: [
            SwitchListTile(
              secondary: Icon(Icons.notifications_outlined,
                  color: Colors.green.shade700),
              title: Text('Push Notifications',
                  style: ubuntuMedium.copyWith(fontSize: 14.sp)),
              subtitle: Text('Train arrival & booking alerts',
                  style: ubuntuRegular.copyWith(
                      fontSize: 11.sp, color: Colors.grey.shade600)),
              value: controller.notificationsEnabled.value,
              activeColor: Colors.green.shade700,
              onChanged: controller.toggleNotifications,
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: Icon(Icons.location_on_outlined,
                  color: Colors.green.shade700),
              title: Text('Auto GPS Location',
                  style: ubuntuMedium.copyWith(fontSize: 14.sp)),
              subtitle: Text('Auto-detect origin for route map',
                  style: ubuntuRegular.copyWith(
                      fontSize: 11.sp, color: Colors.grey.shade600)),
              value: controller.locationEnabled.value,
              activeColor: Colors.green.shade700,
              onChanged: controller.toggleLocation,
            ),
          ],
        );
      }),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard();

  Future<void> _callHotline() async {
    final uri = Uri.parse('tel:16108');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          ListTile(
            leading:
                Icon(Icons.headset_mic_outlined, color: Colors.green.shade700),
            title: Text('DMTCL Customer Hotline',
                style: ubuntuMedium.copyWith(fontSize: 14.sp)),
            subtitle: Text('16108 (24/7 Helpline)',
                style: ubuntuRegular.copyWith(
                    fontSize: 11.sp, color: Colors.grey.shade600)),
            trailing:
                Icon(Icons.phone, color: Colors.green.shade700, size: 20.r),
            onTap: _callHotline,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.help_outline, color: Colors.green.shade700),
            title: Text('Help Center & FAQs',
                style: ubuntuMedium.copyWith(fontSize: 14.sp)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => Get.to(() => const HelpCenterView()),
          ),
          const Divider(height: 1),
          ListTile(
            leading:
                Icon(Icons.privacy_tip_outlined, color: Colors.green.shade700),
            title: Text('Privacy Policy & Terms',
                style: ubuntuMedium.copyWith(fontSize: 14.sp)),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => Get.to(() => const PrivacyPolicyView()),
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        Get.defaultDialog(
          title: 'Log Out',
          middleText: 'Are you sure you want to log out of your MRT account?',
          textConfirm: 'Log Out',
          textCancel: 'Cancel',
          confirmTextColor: Colors.white,
          buttonColor: Colors.red.shade700,
          onConfirm: () async {
            await AuthService.logout();
            Get.back();
            Get.offAllNamed('/');
          },
        );
      },
      icon: const Icon(Icons.logout, color: Colors.red),
      label: Text(
        'Log Out',
        style: ubuntuBold.copyWith(fontSize: 14.sp, color: Colors.red),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        minimumSize: Size(double.infinity, 44.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
