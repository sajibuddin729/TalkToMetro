import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomPopup(String title, String message) {
  Get.defaultDialog(
    title: title,
    middleText: message,
    backgroundColor: Colors.white,
    titleStyle: TextStyle(
      color: Color.fromRGBO(255, 84, 94, 1),
    ),
    middleTextStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w400,
      fontSize: 14,
    ),
    radius: 10,
    barrierDismissible: false, // Prevents closing the dialog by tapping outside
    actions: [
      TextButton(
        onPressed: () {
          Get.back(); // Closes the dialog
        },
        child: Text(
          'OK',
          style: TextStyle(color: Colors.green),
        ),
      ),
    ],
  );
}
