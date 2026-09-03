import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/travel_log/controller/travel_log_controller.dart';
import 'package:mrts/modules/travel_log/model/travel_log_model.dart';
import 'package:mrts/utils/style.dart';

class TravelLogView extends StatefulWidget {
  const TravelLogView({super.key});

  @override
  State<TravelLogView> createState() => _TravelLogViewState();
}

class _TravelLogViewState extends State<TravelLogView> {
  late final TravelLogController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<TravelLogController>()
        ? Get.find<TravelLogController>()
        : Get.put(TravelLogController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade900,
      body: Column(
        children: [
          // ── Green Header with Train Graphic ──────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade900, Colors.green.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_back_ios_new,
                                color: Colors.white, size: 18.r),
                          ),
                        ),
                        Text(
                          'Travel Log',
                          style: ubuntuBold.copyWith(
                            fontSize: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.exportTravelLog,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.ios_share,
                                    color: Colors.white, size: 14.r),
                                SizedBox(width: 4.w),
                                Text(
                                  'Export',
                                  style: ubuntuMedium.copyWith(
                                      fontSize: 12.sp, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Metro Train Banner Graphic Overlay
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.train_outlined,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 24.r),
                        SizedBox(width: 8.w),
                        Text(
                          'DHAKA METRO RAIL JOURNEY LOGS',
                          style: ubuntuBold.copyWith(
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Main Body Card Content ─────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Segmented Tab Selector ───────────────────
                    _buildTabSelector(),
                    SizedBox(height: 16.h),

                    // ── KPI Summary Cards ────────────────────────
                    _buildSummaryKpiRow(),
                    SizedBox(height: 20.h),

                    // ── Travel Log List ──────────────────────────
                    Obx(() {
                      final logsList = controller.filteredLogs;
                      if (logsList.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Column(
                              children: [
                                Icon(Icons.history_toggle_off,
                                    size: 48.r, color: Colors.grey.shade400),
                                SizedBox(height: 8.h),
                                Text(
                                  'No travel logs found.',
                                  style: ubuntuMedium.copyWith(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logsList.length,
                        itemBuilder: (context, index) {
                          final item = logsList[index];
                          return _buildTripLogCard(item);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Segmented Tab Selector Widget (All, Completed, Upcoming)
  Widget _buildTabSelector() {
    final tabs = ['All', 'Completed', 'Upcoming'];
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final activeTab = controller.selectedTab.value;
        return Row(
          children: tabs.map((tab) {
            final isSelected = activeTab == tab;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTab(tab),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0052FF)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    tab,
                    textAlign: TextAlign.center,
                    style: ubuntuBold.copyWith(
                      fontSize: 13.sp,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  /// Summary KPI Cards (Total Trips & This Month Spending)
  Widget _buildSummaryKpiRow() {
    return Obx(() {
      final totalTrips = controller.logs.length;
      final spending = controller.thisMonthSpending;
      final monthTrips = controller.thisMonthTripsCount;

      return Row(
        children: [
          // Total Trips Card
          Expanded(
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEBF3FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.subway_outlined,
                        color: const Color(0xFF0052FF), size: 24.r),
                  ),
                  SizedBox(width: 10.w),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Trips',
                          style: ubuntuRegular.copyWith(
                              fontSize: 11.sp, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$totalTrips',
                          style: ubuntuBold.copyWith(
                              fontSize: 18.sp, color: Colors.black87),
                        ),
                        Text(
                          'All time',
                          style: ubuntuRegular.copyWith(
                              fontSize: 10.sp, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // This Month Spending Card
          Expanded(
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F4EA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet_outlined,
                        color: const Color(0xFF137333), size: 24.r),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Month Spending',
                          style: ubuntuRegular.copyWith(
                              fontSize: 11.sp, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '৳ ${spending.toStringAsFixed(0)}',
                          style: ubuntuBold.copyWith(
                              fontSize: 18.sp, color: Colors.black87),
                        ),
                        Text(
                          '$monthTrips Trips',
                          style: ubuntuRegular.copyWith(
                              fontSize: 10.sp, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Trip Log Card Widget
  Widget _buildTripLogCard(TravelLogModel item) {
    final isCompleted = item.status == 'Completed';
    final isUpcoming = item.status == 'Upcoming';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vertical route dot indicator
              Column(
                children: [
                  Container(
                    width: 14.r,
                    height: 14.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.green.shade600, width: 3),
                    ),
                  ),
                  Container(
                    width: 2.w,
                    height: 24.h,
                    color: Colors.grey.shade300,
                  ),
                  Icon(Icons.arrow_downward,
                      size: 12.r, color: Colors.grey.shade400),
                  Container(
                    width: 2.w,
                    height: 24.h,
                    color: Colors.grey.shade300,
                  ),
                  Container(
                    width: 14.r,
                    height: 14.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.purple.shade600, width: 3),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 14.w),

              // Station Names & Status Pill
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            item.fromStation,
                            style: ubuntuBold.copyWith(
                                fontSize: 14.sp, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Status Badge Pill
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? const Color(0xFFE6F4EA)
                                : (isUpcoming
                                    ? const Color(0xFFE8F0FE)
                                    : Colors.orange.shade50),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.check_circle_outline
                                    : (isUpcoming
                                        ? Icons.access_time
                                        : Icons.info_outline),
                                size: 13.r,
                                color: isCompleted
                                    ? const Color(0xFF137333)
                                    : (isUpcoming
                                        ? const Color(0xFF1A73E8)
                                        : Colors.orange.shade800),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                item.status,
                                style: ubuntuBold.copyWith(
                                  fontSize: 11.sp,
                                  color: isCompleted
                                      ? const Color(0xFF137333)
                                      : (isUpcoming
                                          ? const Color(0xFF1A73E8)
                                          : Colors.orange.shade800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      item.toStation,
                      style: ubuntuBold.copyWith(
                          fontSize: 15.sp, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 10.h),

          // Date, Time, Fare Info Row
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 13.r, color: Colors.grey.shade600),
              SizedBox(width: 4.w),
              Text(
                _formatDate(item.date),
                style: ubuntuRegular.copyWith(
                    fontSize: 11.sp, color: Colors.grey.shade700),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text('|',
                    style: TextStyle(
                        color: Colors.grey.shade300, fontSize: 12.sp)),
              ),
              Icon(Icons.access_time, size: 13.r, color: Colors.grey.shade600),
              SizedBox(width: 4.w),
              Text(
                item.onboardingTime,
                style: ubuntuRegular.copyWith(
                    fontSize: 11.sp, color: Colors.grey.shade700),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Text('|',
                    style: TextStyle(
                        color: Colors.grey.shade300, fontSize: 12.sp)),
              ),
              Icon(Icons.monetization_on_outlined,
                  size: 13.r, color: Colors.grey.shade600),
              SizedBox(width: 4.w),
              Text(
                '৳ ${item.fare.toStringAsFixed(2)}',
                style:
                    ubuntuBold.copyWith(fontSize: 12.sp, color: Colors.black87),
              ),
            ],
          ),

          SizedBox(height: 10.h),
          Divider(color: Colors.grey.shade100, height: 1),
          SizedBox(height: 8.h),

          // Footer Row: View Details & Share Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showTripDetailsBottomSheet(context, item),
                child: Row(
                  children: [
                    Text(
                      'View Details',
                      style: ubuntuBold.copyWith(
                          fontSize: 12.sp, color: const Color(0xFF0052FF)),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.chevron_right,
                        size: 16.r, color: const Color(0xFF0052FF)),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.ios_share,
                    size: 18.r, color: Colors.grey.shade500),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sharing ticket receipt for ${item.id}...'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Show Trip Details Bottom Sheet
  void _showTripDetailsBottomSheet(BuildContext context, TravelLogModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trip Details',
                  style: ubuntuBold.copyWith(
                      fontSize: 16.sp, color: Colors.green.shade900),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    item.trainNumber,
                    style: ubuntuBold.copyWith(
                        fontSize: 12.sp, color: Colors.green.shade800),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _DetailRow(label: 'Trip Reference', value: item.id),
            _DetailRow(label: 'From Station', value: item.fromStation),
            _DetailRow(label: 'To Station', value: item.toStation),
            _DetailRow(label: 'Journey Date', value: _formatDate(item.date)),
            _DetailRow(label: 'Boarding Time', value: item.onboardingTime),
            _DetailRow(label: 'Arrival Time', value: item.arrivalTime),
            _DetailRow(
                label: 'Fare Paid', value: '৳ ${item.fare.toStringAsFixed(2)}'),
            _DetailRow(label: 'Payment Method', value: item.paymentMethod),
            _DetailRow(label: 'Payment Txn Ref', value: item.paymentRef),
            _DetailRow(label: 'Station Gate', value: item.turnstileGate),
            _DetailRow(
              label: 'NFC Pass Status',
              value: item.status == 'Completed' ? 'Validated 🟢' : 'Active 🟡',
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: Size(double.infinity, 46.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Close Details',
                style:
                    ubuntuBold.copyWith(color: Colors.white, fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: ubuntuRegular.copyWith(
                  fontSize: 12.sp, color: Colors.grey.shade600)),
          Text(value,
              style:
                  ubuntuBold.copyWith(fontSize: 12.sp, color: Colors.black87)),
        ],
      ),
    );
  }
}
