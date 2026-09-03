import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        title: Text(
          'Privacy Policy & Terms',
          style: ubuntuBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Talk2Metro (DMTCL)',
                style: ubuntuBold.copyWith(
                    fontSize: 15.sp, color: Colors.green.shade900),
              ),
              SizedBox(height: 4.h),
              Text(
                'Official Mobile Ticketing Privacy Policy',
                style: ubuntuMedium.copyWith(
                    fontSize: 12.sp, color: Colors.grey.shade600),
              ),
              SizedBox(height: 16.h),
              _sectionTitle('1. Information We Collect'),
              _sectionBody(
                  'We collect basic user profile information (Name, Phone number, Email), MRT/Rapid Pass identification numbers, and GPS location data (strictly used for origin/destination route mapping when enabled).'),
              SizedBox(height: 12.h),
              _sectionTitle('2. Payment & Transaction Security'),
              _sectionBody(
                  'All ticketing and Rapid Pass recharge transactions are processed securely via encrypted payment gateways (bKash, Nagad, Visa/Mastercard). Payment details are never stored on DMTCL servers.'),
              SizedBox(height: 12.h),
              _sectionTitle('3. Location Data Usage'),
              _sectionBody(
                  'GPS location permissions are utilized exclusively to locate your nearest Metro station and provide real-time route directions. You may disable location permissions at any time in Settings.'),
              SizedBox(height: 12.h),
              _sectionTitle('4. Contact & Support'),
              _sectionBody(
                  'For inquiries regarding privacy, ticket refunds, or pass blocking, contact DMTCL Customer Support at hotline 16108 or email support@dmtcl.gov.bd.'),
              SizedBox(height: 20.h),
              Center(
                child: Text(
                  'Last Updated: July 2026',
                  style: ubuntuRegular.copyWith(
                      fontSize: 11.sp, color: Colors.grey.shade500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: ubuntuBold.copyWith(fontSize: 13.sp, color: Colors.black87),
    );
  }

  Widget _sectionBody(String body) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Text(
        body,
        style: ubuntuRegular.copyWith(
          fontSize: 12.sp,
          color: Colors.grey.shade700,
          height: 1.4,
        ),
      ),
    );
  }
}
