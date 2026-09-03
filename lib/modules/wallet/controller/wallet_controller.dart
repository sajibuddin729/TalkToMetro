import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrts/services/payment_service.dart';

/// Wallet Transaction model
class WalletTransaction {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
  final String paymentMethod;
  final String? transactionRef; // SSLCommerz transaction reference

  WalletTransaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.paymentMethod,
    this.transactionRef,
  });
}

/// Wallet Controller
/// Manages wallet balance and transactions.
/// Top-up payments go through SSLCommerz gateway (bKash, Nagad, Card).
/// Ticket deduction uses wallet balance directly.
class WalletController extends GetxController implements GetxService {
  final walletBalance = 1250.0.obs;
  final isPaymentLoading = false.obs;

  final transactions = <WalletTransaction>[
    WalletTransaction(
      id: 'TXN-9021',
      title: 'Wallet Add Money (bKash)',
      date: '22 Jul 2026, 02:30 PM',
      amount: 1000.0,
      isCredit: true,
      paymentMethod: 'bKash',
      transactionRef: 'BKASH-TXN-2206-9021',
    ),
    WalletTransaction(
      id: 'TXN-8842',
      title: 'Ticket: Uttara North ➔ Motijheel',
      date: '21 Jul 2026, 08:45 AM',
      amount: 100.0,
      isCredit: false,
      paymentMethod: 'Wallet',
    ),
    WalletTransaction(
      id: 'TXN-7612',
      title: 'Ticket: Mirpur 10 ➔ Farmgate',
      date: '20 Jul 2026, 05:15 PM',
      amount: 30.0,
      isCredit: false,
      paymentMethod: 'Wallet',
    ),
    WalletTransaction(
      id: 'TXN-6501',
      title: 'Wallet Add Money (Visa)',
      date: '18 Jul 2026, 11:10 AM',
      amount: 500.0,
      isCredit: true,
      paymentMethod: 'Visa',
      transactionRef: 'VISA-TXN-1807-6501',
    ),
  ].obs;

  Future<void> getData() async {
    // Controller initialization hook — can load from Firestore here
  }

  /// Add money to wallet via SSLCommerz payment gateway
  /// This is the real payment flow — opens SSLCommerz in-app payment screen
  Future<bool> addMoneyViaSSLCommerz({
    required double amount,
    required String method,
    required String customerName,
    required String customerPhone,
    required String customerEmail,
  }) async {
    isPaymentLoading.value = true;

    try {
      final result = await PaymentService().initiateWalletTopUp(
        amount: amount,
        paymentMethod: method,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
      );

      if (result.status == PaymentStatus.success) {
        // Payment succeeded — credit wallet
        walletBalance.value += amount;
        _insertTransaction(
          title: 'Wallet Add Money ($method)',
          amount: amount,
          isCredit: true,
          paymentMethod: method,
          transactionRef: result.transactionId,
        );
        PaymentService.showSuccessSnackbar(
          '৳${amount.toStringAsFixed(0)} added to your Metro Wallet via $method!',
        );
        return true;
      } else if (result.status == PaymentStatus.cancelled) {
        PaymentService.showFailureSnackbar('Payment cancelled.');
        return false;
      } else {
        PaymentService.showFailureSnackbar(
          result.errorMessage ?? 'Payment failed. Please try again.',
        );
        return false;
      }
    } finally {
      isPaymentLoading.value = false;
    }
  }

  /// Legacy addMoney — kept for direct/wallet payments (no SSLCommerz)
  void addMoney(double amount, String method) {
    walletBalance.value += amount;
    _insertTransaction(
      title: 'Wallet Add Money ($method)',
      amount: amount,
      isCredit: true,
      paymentMethod: method,
    );

    final ctx = Get.context;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
              '৳${amount.toStringAsFixed(0)} added to your Metro Wallet successfully!'),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Deduct fare from wallet balance
  /// Returns true if deduction successful, false if insufficient balance
  bool deductFare(double amount, String details) {
    if (walletBalance.value < amount) {
      final ctx = Get.context;
      if (ctx != null) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(
            content: const Text('Insufficient wallet balance! Please add money.'),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }

    walletBalance.value -= amount;
    _insertTransaction(
      title: details,
      amount: amount,
      isCredit: false,
      paymentMethod: 'Wallet',
    );
    return true;
  }

  /// Internal helper — insert transaction at top of list
  void _insertTransaction({
    required String title,
    required double amount,
    required bool isCredit,
    required String paymentMethod,
    String? transactionRef,
  }) {
    final now = DateTime.now();
    final dateStr =
        '${now.day} ${_monthName(now.month)} ${now.year}, ${_formatTime(now)}';
    final txnId = 'TXN-${(1000 + transactions.length + 1).toString()}';

    transactions.insert(
      0,
      WalletTransaction(
        id: txnId,
        title: title,
        date: dateStr,
        amount: amount,
        isCredit: isCredit,
        paymentMethod: paymentMethod,
        transactionRef: transactionRef,
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} $amPm';
  }
}