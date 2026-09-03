import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrts/modules/home/view/homepage.dart';
import 'package:mrts/utils/dimensions.dart';

class Confirmation extends StatefulWidget {
  final String fromStation;
  final String toStation;
  final String trainNumber;
  final double fare;
  final DateTime date;
  final String onboardingTime;
  final String arrivalTime;
  final int numberOfTickets;
  final String paymentMethod;
  final String paymentRef;

  const Confirmation({
    super.key,
    required this.fromStation,
    required this.toStation,
    required this.trainNumber,
    required this.fare,
    required this.date,
    required this.onboardingTime,
    required this.arrivalTime,
    required this.numberOfTickets,
    this.paymentMethod = 'Metro Digital Wallet',
    this.paymentRef = 'N/A',
  });

  @override
  State<Confirmation> createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation>
    with SingleTickerProviderStateMixin {
  late AnimationController _nfcPulseController;
  bool _isConnectingNfc = false;

  @override
  void initState() {
    super.initState();
    _nfcPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nfcPulseController.dispose();
    super.dispose();
  }

  void _simulateNfcGateTap() {
    setState(() => _isConnectingNfc = true);

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isConnectingNfc = false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 28.r),
              SizedBox(width: 10.w),
              Text(
                'Gate Unlocked 🟢',
                style: TextStyle(
                    fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NFC Contactless Pass Validated!',
                style: TextStyle(
                    fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                'Station: ${widget.fromStation} Turnstile #04\n'
                'Status: Valid for Entry & Exit\n'
                'Have a safe journey on Dhaka Metro Rail Line 6!',
                style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                    height: 1.4),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Get.offAll(() => const HomePage());
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700),
              child: const Text('Back to Home',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalFare = widget.fare * widget.numberOfTickets;
    final passId =
        'NFC-DMR-${widget.date.millisecondsSinceEpoch.toString().substring(6)}';

    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(
          'Contactless NFC Pass',
          style: GoogleFonts.ubuntu(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // ── NFC Ticket Card ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade900, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DHAKA METRO RAIL LINE 6',
                        style: GoogleFonts.ubuntu(
                          fontSize: 12.sp,
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      FadeTransition(
                        opacity: _nfcPulseController,
                        child:
                            Icon(Icons.nfc, color: Colors.white, size: 28.r),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'SINGLE JOURNEY CONTACTLESS PASS',
                      style: GoogleFonts.ubuntu(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Route
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ORIGIN',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.white60)),
                          Text(widget.fromStation,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('Dep: ${widget.onboardingTime}',
                              style: TextStyle(
                                  fontSize: 11.sp, color: Colors.white70)),
                        ],
                      ),
                      Icon(Icons.east, color: Colors.white, size: 24.r),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('DESTINATION',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.white60)),
                          Text(widget.toStation,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          Text('Arr: ${widget.arrivalTime}',
                              style: TextStyle(
                                  fontSize: 11.sp, color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),
                  Divider(color: Colors.white.withValues(alpha: 0.3)),
                  SizedBox(height: 10.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PASS ID',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.white60)),
                          Text(passId,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TRAIN NO.',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.white60)),
                          Text(widget.trainNumber,
                              style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('PAID FARE',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.white60)),
                          Text(
                            '৳ ${totalFare.toStringAsFixed(0)}',
                            style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ── Payment Info Card ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green.shade700, size: 18.r),
                      SizedBox(width: 8.w),
                      Text(
                        'Payment Successful',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  _PaymentInfoRow(
                      label: 'Method', value: widget.paymentMethod),
                  _PaymentInfoRow(
                      label: 'Amount',
                      value: '৳ ${totalFare.toStringAsFixed(2)}'),
                  _PaymentInfoRow(
                      label: 'Passengers', value: '${widget.numberOfTickets}'),
                  if (widget.paymentRef != 'N/A' &&
                      widget.paymentRef != 'WALLET-PAY')
                    _PaymentInfoRow(
                        label: 'Txn Ref', value: widget.paymentRef),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ── NFC Gate Scanner ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _nfcPulseController,
                    child: Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.nfc,
                        size: 54.r,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    _isConnectingNfc
                        ? 'Connecting to Station Turnstile Gate...'
                        : 'Hold Phone Near Turnstile Gate Reader',
                    style: GoogleFonts.ubuntu(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'NFC Contactless Pass active. Tap below to simulate station gate scan.',
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  if (_isConnectingNfc)
                    CircularProgressIndicator(color: Colors.green.shade700)
                  else
                    ElevatedButton.icon(
                      onPressed: _simulateNfcGateTap,
                      icon: Icon(Icons.tap_and_play,
                          color: Colors.white, size: 20.r),
                      label: Text(
                        'Tap NFC at Turnstile Gate',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        minimumSize: Size(double.infinity, 48.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => Get.offAll(() => const HomePage()),
              child: Text(
                'Back to Home Screen',
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Payment info row widget
class _PaymentInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _PaymentInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: Colors.green.shade700)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
