import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/settings/controller/settings_controller.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class MrtPassView extends StatefulWidget {
  const MrtPassView({super.key});

  @override
  State<MrtPassView> createState() => _MrtPassViewState();
}

class _MrtPassViewState extends State<MrtPassView> {
  final SettingsController c = Get.find<SettingsController>();
  double _selectedAmount = 200.0;
  String _selectedMethod = 'bKash';

  final List<double> _amounts = [100.0, 200.0, 500.0, 1000.0];
  final List<Map<String, String>> _methods = [
    {'name': 'bKash', 'type': 'bKash'},
    {'name': 'Nagad', 'type': 'Nagad'},
    {'name': 'Card', 'type': 'Visa/Mastercard'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        title: Text(
          'MRT / Rapid Pass',
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
            _CardDetailsWidget(controller: c),
            SizedBox(height: 20.h),
            Text(
              'Recharge Pass',
              style: ubuntuBold.copyWith(fontSize: 16.sp, color: Colors.green.shade900),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Amount (BDT)',
                    style: ubuntuMedium.copyWith(fontSize: 13.sp, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _amounts.map((amount) {
                      final isSelected = _selectedAmount == amount;
                      return ChoiceChip(
                        label: Text('৳ ${amount.toInt()}'),
                        selected: isSelected,
                        selectedColor: Colors.green.shade700,
                        labelStyle: ubuntuBold.copyWith(
                          fontSize: 13.sp,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        onSelected: (_) => setState(() => _selectedAmount = amount),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Payment Method',
                    style: ubuntuMedium.copyWith(fontSize: 13.sp, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: _methods.map((item) {
                      final isSelected = _selectedMethod == item['name'];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: InkWell(
                            onTap: () => setState(() => _selectedMethod = item['name']!),
                            borderRadius: BorderRadius.circular(8.r),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
                                border: Border.all(
                                  color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                item['name']!,
                                textAlign: TextAlign.center,
                                style: ubuntuBold.copyWith(
                                  fontSize: 13.sp,
                                  color: isSelected ? Colors.green.shade800 : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20.h),
                  Obx(() => c.isRechargeLoading.value
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.r),
                            child: CircularProgressIndicator(
                              color: Colors.green.shade700,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            c.rechargePassViaSSLCommerz(
                              amount: _selectedAmount,
                              method: _selectedMethod,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            minimumSize: Size(double.infinity, 44.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock, color: Colors.white, size: 16.r),
                              SizedBox(width: 6.w),
                              Text(
                                'Confirm Recharge ৳${_selectedAmount.toInt()}',
                                style: ubuntuBold.copyWith(
                                    fontSize: 14.sp, color: Colors.white),
                              ),
                            ],
                          ),
                        )),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.security, size: 11.r, color: Colors.grey.shade500),
                      SizedBox(width: 4.w),
                      Text(
                        'Secured by SSLCommerz',
                        style: ubuntuRegular.copyWith(
                            fontSize: 11.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Recent Transactions',
              style: ubuntuBold.copyWith(fontSize: 16.sp, color: Colors.green.shade900),
            ),
            SizedBox(height: 10.h),
            Obx(() {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: c.transactions.length,
                itemBuilder: (context, index) {
                  final tx = c.transactions[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.r),
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
                              tx.isRecharge ? Colors.green.shade100 : Colors.orange.shade100,
                          child: Icon(
                            tx.isRecharge ? Icons.add : Icons.subway,
                            color: tx.isRecharge ? Colors.green.shade800 : Colors.orange.shade900,
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
                                    fontSize: 13.sp, color: Colors.black87),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                tx.date,
                                style: ubuntuRegular.copyWith(
                                    fontSize: 11.sp, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${tx.isRecharge ? '+' : '-'}৳${tx.amount.toStringAsFixed(0)}',
                          style: ubuntuBold.copyWith(
                            fontSize: 14.sp,
                            color: tx.isRecharge ? Colors.green.shade800 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CardDetailsWidget extends StatelessWidget {
  const _CardDetailsWidget({required this.controller});
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
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
                Text(
                  'RAPID PASS / MRT PASS',
                  style: ubuntuBold.copyWith(
                    fontSize: 13.sp,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
                Icon(Icons.nfc, color: Colors.white, size: 24.r),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              controller.mrtPassId.value,
              style: ubuntuBold.copyWith(
                fontSize: 18.sp,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARD HOLDER',
                      style: ubuntuRegular.copyWith(fontSize: 10.sp, color: Colors.white60),
                    ),
                    Text(
                      controller.userName.value.toUpperCase(),
                      style: ubuntuBold.copyWith(fontSize: 12.sp, color: Colors.white),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'BALANCE',
                      style: ubuntuRegular.copyWith(fontSize: 10.sp, color: Colors.white60),
                    ),
                    Text(
                      '৳ ${controller.mrtPassBalance.value.toStringAsFixed(2)}',
                      style: ubuntuBold.copyWith(fontSize: 16.sp, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
