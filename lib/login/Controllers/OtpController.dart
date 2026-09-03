import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  // Lists to hold the controllers and focus nodes
  final otpControllers = List.generate(6, (_) => TextEditingController()).obs;
  final otpFocusNodes = List.generate(6, (_) => FocusNode()).obs;
  final otpFillColors = List.generate(6, (_) => Rx<Color>(Colors.grey.shade200)).obs;

  @override
  void onClose() {
    // Dispose controllers and focus nodes
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in otpFocusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}
