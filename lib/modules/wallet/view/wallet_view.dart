import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/wallet/controller/wallet_controller.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/style.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletController controller = Get.put(WalletController());
  double _selectedAmount = 200.0;
  String _selectedMethod = 'bKash';

  // Custom amount controller
  final _customAmountController = TextEditingController();
  bool _useCustomAmount = false;

  final List<double> _amounts = [100.0, 200.0, 500.0, 1000.0];

  final List<Map<String, dynamic>> _methods = [
    {
      'name': 'bKash',
      'label': 'bKash',
      'asset': 'images/bkash.png',
      'color': const Color(0xFFE2136E),
      'description': 'bKash Mobile Banking',
    },
    {
      'name': 'Nagad',
      'label': 'Nagad',
      'asset': 'nagad_badge',
      'color': const Color(0xFFFF6B00),
      'description': 'Nagad Digital Payment',
    },
    {
      'name': 'Visa/Mastercard',
      'label': 'Visa / MasterCard',
      'asset': 'cards',
      'color': const Color(0xFF1A1F71),
      'description': 'Debit / Credit Card',
    },
    {
      'name': 'All',
      'label': 'All Payment Methods',
      'asset': 'all_methods',
      'color': Colors.teal,
      'description': 'bKash, Nagad, Cards & NetBanking',
    },
  ];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  double get _finalAmount {
    if (_useCustomAmount) {
      return double.tryParse(_customAmountController.text) ?? _selectedAmount;
    }
    return _selectedAmount;
  }

  void _onAddMoneyPressed() async {
    final amount = _finalAmount;

    if (amount < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Minimum top-up amount is ৳10'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (amount > 50000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Maximum top-up amount is ৳50,000'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show payment confirmation dialog
    final confirmed = await _showPaymentConfirmDialog(amount);
    if (!confirmed) return;

    // Trigger SSLCommerz payment
    await controller.addMoneyViaSSLCommerz(
      amount: amount,
      method: _selectedMethod,
      customerName: 'Metro Passenger',
      customerPhone: '01700000000',
      customerEmail: 'passenger@metrorail.bd',
    );
  }

  Future<bool> _showPaymentConfirmDialog(double amount) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r)),
            title: Row(
              children: [
                Icon(Icons.payment, color: Colors.green.shade700, size: 24.r),
                SizedBox(width: 8.w),
                Text(
                  'Confirm Payment',
                  style: ubuntuBold.copyWith(fontSize: 16.sp),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogRow(label: 'Amount', value: '৳ ${amount.toStringAsFixed(0)}'),
                SizedBox(height: 6.h),
                _DialogRow(label: 'Method', value: _selectedMethod),
                SizedBox(height: 6.h),
                _DialogRow(label: 'Destination', value: 'Metro Digital Wallet'),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16.r),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'You will be redirected to SSLCommerz secure payment gateway inside the app.',
                          style: ubuntuRegular.copyWith(
                              fontSize: 11.sp, color: Colors.blue.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: ubuntuMedium.copyWith(
                        color: Colors.grey.shade600, fontSize: 13.sp)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Pay Now',
                    style: ubuntuBold.copyWith(
                        color: Colors.white, fontSize: 13.sp)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: Text(
          'Metro Wallet',
          style: ubuntuBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WalletBalanceCard(controller: controller),
            SizedBox(height: 20.h),

            // ── Add Money Section ─────────────────────────────────
            Text(
              'Add Money to Wallet',
              style: ubuntuBold.copyWith(
                  fontSize: 16.sp, color: Colors.green.shade900),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount selector
                  Text(
                    'Select Amount (BDT)',
                    style: ubuntuMedium.copyWith(
                        fontSize: 13.sp, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      ..._amounts.map((amount) {
                        final isSelected =
                            !_useCustomAmount && _selectedAmount == amount;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedAmount = amount;
                            _useCustomAmount = false;
                            _customAmountController.clear();
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.green.shade700
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.green.shade700
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              '৳ ${amount.toInt()}',
                              style: ubuntuBold.copyWith(
                                fontSize: 13.sp,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }),
                      // Custom amount chip
                      GestureDetector(
                        onTap: () => setState(() => _useCustomAmount = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _useCustomAmount
                                ? Colors.green.shade700
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: _useCustomAmount
                                  ? Colors.green.shade700
                                  : Colors.grey.shade300,
                              width: _useCustomAmount ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            'Custom',
                            style: ubuntuBold.copyWith(
                              fontSize: 13.sp,
                              color: _useCustomAmount
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Custom amount text field
                  if (_useCustomAmount) ...[
                    SizedBox(height: 12.h),
                    TextField(
                      controller: _customAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Enter Amount (BDT)',
                        prefixText: '৳ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                              color: Colors.green.shade700, width: 2),
                        ),
                        hintText: 'e.g. 250',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],

                  SizedBox(height: 18.h),

                  // Payment method selector with BRAND LOGOS
                  Text(
                    'Payment Method',
                    style: ubuntuMedium.copyWith(
                        fontSize: 13.sp, color: Colors.grey.shade700),
                  ),
                  SizedBox(height: 10.h),
                  ...(_methods.map((item) {
                    final isSelected = _selectedMethod == item['name'];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedMethod = item['name'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.only(bottom: 8.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (item['color'] as Color).withValues(alpha: 0.08)
                              : Colors.grey.shade50,
                          border: Border.all(
                            color: isSelected
                                ? item['color'] as Color
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            PaymentBrandIcon(assetType: item['asset'] as String),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['label'] as String,
                                    style: ubuntuBold.copyWith(
                                      fontSize: 14.sp,
                                      color: isSelected
                                          ? item['color'] as Color
                                          : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    item['description'] as String,
                                    style: ubuntuRegular.copyWith(
                                        fontSize: 11.sp,
                                        color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: item['color'] as Color, size: 22.r),
                          ],
                        ),
                      ),
                    );
                  })),

                  SizedBox(height: 20.h),

                  // Add Money Button
                  Obx(() => controller.isPaymentLoading.value
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.r),
                            child: CircularProgressIndicator(
                              color: Colors.green.shade700,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _onAddMoneyPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            minimumSize: Size(double.infinity, 48.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock, color: Colors.white, size: 16.r),
                              SizedBox(width: 8.w),
                              Text(
                                'Add ৳${_finalAmount.toInt()} via $_selectedMethod',
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
                      Icon(Icons.security,
                          size: 12.r, color: Colors.grey.shade500),
                      SizedBox(width: 4.w),
                      Text(
                        'Secured by SSLCommerz — 100% Safe Sandbox',
                        style: ubuntuRegular.copyWith(
                            fontSize: 11.sp, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── Transaction History ────────────────────────────────
            Text(
              'Wallet History',
              style: ubuntuBold.copyWith(
                  fontSize: 16.sp, color: Colors.green.shade900),
            ),
            SizedBox(height: 10.h),
            Obx(() {
              if (controller.transactions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      'No transactions yet.',
                      style: ubuntuRegular.copyWith(
                          fontSize: 13.sp, color: Colors.grey),
                    ),
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
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
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
                          radius: 20.r,
                          backgroundColor: tx.isCredit
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            tx.isCredit ? Icons.add_card : Icons.subway,
                            color: tx.isCredit
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                            size: 20.r,
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
                                '${tx.date} • ${tx.id}',
                                style: ubuntuRegular.copyWith(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600),
                              ),
                              if (tx.transactionRef != null)
                                Text(
                                  'Ref: ${tx.transactionRef}',
                                  style: ubuntuRegular.copyWith(
                                    fontSize: 10.sp,
                                    color: Colors.blue.shade400,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          '${tx.isCredit ? '+' : '-'}৳${tx.amount.toStringAsFixed(0)}',
                          style: ubuntuBold.copyWith(
                            fontSize: 15.sp,
                            color: tx.isCredit
                                ? Colors.green.shade800
                                : Colors.red.shade800,
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

/// Brand Icon Widget for bKash, Nagad, Visa, Mastercard, All
class PaymentBrandIcon extends StatelessWidget {
  final String assetType;
  const PaymentBrandIcon({super.key, required this.assetType});

  @override
  Widget build(BuildContext context) {
    if (assetType == 'images/bkash.png') {
      return Container(
        width: 36.w,
        height: 36.h,
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: const Color(0xFFE2136E).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Image.asset('images/bkash.png', fit: BoxFit.contain),
      );
    } else if (assetType == 'nagad_badge') {
      return Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B00),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            'নগদ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ),
      );
    } else if (assetType == 'cards') {
      return Container(
        width: 44.w,
        height: 36.h,
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/visacard.png', width: 18.w, fit: BoxFit.contain),
            SizedBox(width: 2.w),
            Image.asset('images/mastercard.png', width: 18.w, fit: BoxFit.contain),
          ],
        ),
      );
    } else {
      return Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(Icons.payment, color: Colors.teal.shade700, size: 22.r),
      );
    }
  }
}

/// Dialog row widget
class _DialogRow extends StatelessWidget {
  final String label;
  final String value;
  const _DialogRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

/// Wallet Balance Card widget
class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard({required this.controller});
  final WalletController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade900, Colors.green.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              blurRadius: 12,
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
                    Icon(Icons.account_balance_wallet,
                        color: Colors.white, size: 24.r),
                    SizedBox(width: 8.w),
                    Text(
                      'METRO DIGITAL WALLET',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
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
                  child: const Text(
                    'SSL Pay',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Available Balance',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '৳ ${controller.walletBalance.value.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      );
    });
  }
}