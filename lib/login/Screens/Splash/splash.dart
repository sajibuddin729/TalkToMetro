import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrts/login/Screens/OTP/otp.dart';
import 'package:mrts/modules/home/view/homepage.dart';
import 'package:mrts/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(-1.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 1.0, curve: Curves.fastOutSlowIn),
      ),
    );

    _animController.forward();

    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    final isValidSession = await AuthService.isSessionValid();

    if (isValidSession) {
      Get.offAll(() => const HomePage());
    } else {
      Get.offAll(() => const OtpPage());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: const Color.fromRGBO(235, 243, 241, 1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // Animated Logo & Scale
            ScaleTransition(
              scale: _scaleAnim,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SvgPicture.asset(
                  'assets/metroLogoOnly.svg',
                  height: 140.h,
                ),
              ),
            ),

            SizedBox(height: 12.h),

            FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  Text(
                    'Talk2Metro',
                    style: GoogleFonts.poppins(
                      color: const Color.fromRGBO(90, 117, 112, 1),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      letterSpacing: .5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'DHAKA METRO RAIL LINE',
                    style: GoogleFonts.ubuntu(
                      color: Colors.green.shade800,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Animated Train Sliding Across Screen
            SlideTransition(
              position: _slideAnim,
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.train,
                  size: 40.r,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            FadeTransition(
              opacity: _fadeAnim,
              child: SizedBox(
                width: 140.w,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.green.shade100,
                  color: Colors.green.shade700,
                  minHeight: 4.h,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
