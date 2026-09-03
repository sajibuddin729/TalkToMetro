import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class HelpCenterView extends StatelessWidget {
  const HelpCenterView({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I purchase a single-journey Metro ticket?',
      'answer':
          'Select your Origin and Destination station on the Home screen or Ticket Search page, choose the number of passengers, and complete payment via bKash, Nagad, or Card.',
    },
    {
      'question': 'What is Rapid Pass / MRT Pass?',
      'answer':
          'Rapid Pass / MRT Pass is a contactless smart card used for seamless travel on Dhaka Metro Line 6. Pass holders get a 10% discount on standard fares.',
    },
    {
      'question': 'How do I recharge my MRT Pass online?',
      'answer':
          'Go to Settings > MRT / Rapid Pass, choose your recharge amount, select payment method (bKash/Nagad/Card), and confirm.',
    },
    {
      'question': 'What are the Metro Rail operating hours?',
      'answer':
          'Weekdays (Sun–Thu): 06:30 AM – 10:10 PM\nFriday: 03:00 PM – 09:40 PM\nSaturday: 06:30 AM – 09:40 PM\nTrain frequency: Every 6 min (peak), 8 min (off-peak), 10–15 min (evening).',
    },
    {
      'question': 'What should I do if I lose my MRT Pass?',
      'answer':
          'Report the lost card immediately at any station customer service desk or call 16108 to block the card and transfer your balance to a new card.',
    },
    {
      'question': 'Is there a student or children discount?',
      'answer':
          'Children under 5 years travel free when accompanied by an adult. Currently, there is no separate student concession.',
    },
  ];

  Future<void> _callHotline() async {
    final uri = Uri.parse('tel:16108');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        title: Text(
          'Help Center & FAQs',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.headset_mic, color: Colors.green.shade800, size: 32.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Instant Help?',
                          style: ubuntuBold.copyWith(
                              fontSize: 14.sp, color: Colors.green.shade900),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Call DMTCL 24/7 Hotline at 16108',
                          style: ubuntuRegular.copyWith(
                              fontSize: 12.sp, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _callHotline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    ),
                    child: Text('Call Now',
                        style: ubuntuBold.copyWith(fontSize: 12.sp, color: Colors.white)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Frequently Asked Questions',
              style: ubuntuBold.copyWith(fontSize: 16.sp, color: Colors.green.shade900),
            ),
            SizedBox(height: 10.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      faq['question']!,
                      style: ubuntuMedium.copyWith(fontSize: 13.sp, color: Colors.black87),
                    ),
                    iconColor: Colors.green.shade700,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                        child: Text(
                          faq['answer']!,
                          style: ubuntuRegular.copyWith(
                            fontSize: 12.sp,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
