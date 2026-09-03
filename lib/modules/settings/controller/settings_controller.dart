import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/wallet/controller/wallet_controller.dart';
import 'package:mrts/services/payment_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MrtTransaction {
  final String title;
  final String date;
  final double amount;
  final bool isRecharge;

  const MrtTransaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.isRecharge,
  });
}

class SettingsController extends GetxController {
  final userName = 'Sajib Ahmed'.obs;
  final userPhone = '+880 1712-345678'.obs;
  final userEmail = 'sajib.metro@example.com'.obs;
  final mrtPassId = 'MRT-88392011'.obs;
  final preferredStation = 'Uttara North'.obs;
  final profileImagePath = ''.obs; // Path to locally saved profile image

  final mrtPassBalance = 550.0.obs;
  final isRechargeLoading = false.obs;

  final notificationsEnabled = true.obs;
  final locationEnabled = true.obs;

  final transactions = <MrtTransaction>[
    const MrtTransaction(
      title: 'Recharge via bKash',
      date: '22 Jul 2026, 04:15 PM',
      amount: 500.0,
      isRecharge: true,
    ),
    const MrtTransaction(
      title: 'Trip: Uttara North ➔ Farmgate',
      date: '21 Jul 2026, 09:30 AM',
      amount: 50.0,
      isRecharge: false,
    ),
    const MrtTransaction(
      title: 'Trip: Farmgate ➔ Motijheel',
      date: '20 Jul 2026, 05:45 PM',
      amount: 30.0,
      isRecharge: false,
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileFromPrefs();
  }

  /// Load saved profile data from SharedPreferences
  Future<void> _loadProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('profile_name');
    final savedPhone = prefs.getString('profile_phone');
    final savedEmail = prefs.getString('profile_email');
    final savedStation = prefs.getString('profile_station');
    final savedImagePath = prefs.getString('profile_image_path');

    if (savedName != null) userName.value = savedName;
    if (savedPhone != null) userPhone.value = savedPhone;
    if (savedEmail != null) userEmail.value = savedEmail;
    if (savedStation != null) preferredStation.value = savedStation;
    if (savedImagePath != null && savedImagePath.isNotEmpty) {
      profileImagePath.value = savedImagePath;
    }
  }

  /// Update profile and persist to SharedPreferences
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String email,
    required String station,
    String? imagePath,
  }) async {
    userName.value = name;
    userPhone.value = phone;
    userEmail.value = email;
    preferredStation.value = station;
    if (imagePath != null && imagePath.isNotEmpty) {
      profileImagePath.value = imagePath;
    }

    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
    await prefs.setString('profile_phone', phone);
    await prefs.setString('profile_email', email);
    await prefs.setString('profile_station', station);
    if (imagePath != null && imagePath.isNotEmpty) {
      await prefs.setString('profile_image_path', imagePath);
    }

    _showSnack('Profile Updated — Your information has been saved.');
  }

  /// Update only profile image path and persist
  Future<void> updateProfileImage(String path) async {
    profileImagePath.value = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  /// Recharge MRT Pass via SSLCommerz payment gateway
  Future<bool> rechargePassViaSSLCommerz({
    required double amount,
    required String method,
  }) async {
    isRechargeLoading.value = true;

    try {
      final result = await PaymentService().initiateWalletTopUp(
        amount: amount,
        paymentMethod: method,
        customerName: userName.value,
        customerPhone: userPhone.value,
        customerEmail: userEmail.value,
      );

      if (result.status == PaymentStatus.success) {
        mrtPassBalance.value += amount;

        if (Get.isRegistered<WalletController>()) {
          final walletCtrl = Get.find<WalletController>();
          walletCtrl.walletBalance.value += amount;
          walletCtrl.transactions.insert(
            0,
            WalletTransaction(
              id: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              title: 'MRT Pass Recharge ($method)',
              date: 'Just now',
              amount: amount,
              isCredit: true,
              paymentMethod: method,
              transactionRef: result.transactionId,
            ),
          );
        }

        transactions.insert(
          0,
          MrtTransaction(
            title: 'Recharge via $method',
            date: 'Just now',
            amount: amount,
            isRecharge: true,
          ),
        );

        PaymentService.showSuccessSnackbar(
          '৳${amount.toStringAsFixed(0)} recharged successfully to your MRT Pass!',
        );
        return true;
      } else if (result.status == PaymentStatus.cancelled) {
        PaymentService.showFailureSnackbar('Recharge cancelled.');
        return false;
      } else {
        PaymentService.showFailureSnackbar(
          result.errorMessage ?? 'Recharge failed. Please try again.',
        );
        return false;
      }
    } finally {
      isRechargeLoading.value = false;
    }
  }

  void toggleNotifications(bool val) {
    notificationsEnabled.value = val;
  }

  void toggleLocation(bool val) {
    locationEnabled.value = val;
  }

  void _showSnack(String message) {
    final ctx = Get.context;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
