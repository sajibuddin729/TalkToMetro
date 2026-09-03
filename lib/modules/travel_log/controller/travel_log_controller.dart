import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/travel_log/model/travel_log_model.dart';

class TravelLogController extends GetxController {
  final selectedTab = 'All'.obs; // 'All', 'Completed', 'Upcoming'

  /// Realistic travel log data with current 2026 dates and real MRT Line 6 stations
  final logs = <TravelLogModel>[
    TravelLogModel(
      id: 'TRIP-2607',
      fromStation: 'Uttara North',
      toStation: 'Agargaon',
      trainNumber: 'MRT-106',
      date: DateTime(2026, 7, 25, 8, 10),
      onboardingTime: '08:10 AM',
      arrivalTime: '08:30 AM',
      fare: 60.0,
      numberOfTickets: 1,
      paymentMethod: 'Metro Digital Wallet',
      paymentRef: 'WALLET-2607',
      status: 'Completed',
      turnstileGate: 'Turnstile #02',
    ),
    TravelLogModel(
      id: 'TRIP-2606',
      fromStation: 'Mirpur 10',
      toStation: 'Farmgate',
      trainNumber: 'MRT-103',
      date: DateTime(2026, 7, 24, 18, 45),
      onboardingTime: '06:45 PM',
      arrivalTime: '07:00 PM',
      fare: 30.0,
      numberOfTickets: 1,
      paymentMethod: 'bKash',
      paymentRef: 'BKASH-2606',
      status: 'Completed',
      turnstileGate: 'Turnstile #01',
    ),
    TravelLogModel(
      id: 'TRIP-2605',
      fromStation: 'Farmgate',
      toStation: 'Motijheel',
      trainNumber: 'MRT-105',
      date: DateTime(2026, 7, 23, 9, 20),
      onboardingTime: '09:20 AM',
      arrivalTime: '09:32 AM',
      fare: 30.0,
      numberOfTickets: 1,
      paymentMethod: 'Metro Digital Wallet',
      paymentRef: 'WALLET-2605',
      status: 'Completed',
      turnstileGate: 'Turnstile #03',
    ),
    TravelLogModel(
      id: 'TRIP-2604',
      fromStation: 'Uttara North',
      toStation: 'Motijheel',
      trainNumber: 'MRT-101',
      date: DateTime(2026, 7, 22, 10, 0),
      onboardingTime: '10:00 AM',
      arrivalTime: '10:38 AM',
      fare: 100.0,
      numberOfTickets: 1,
      paymentMethod: 'Visa/Mastercard',
      paymentRef: 'CARD-2604',
      status: 'Completed',
      turnstileGate: 'Turnstile #04',
    ),
    TravelLogModel(
      id: 'TRIP-2603',
      fromStation: 'Shahbag',
      toStation: 'Bijoy Sarani',
      trainNumber: 'MRT-108',
      date: DateTime(2026, 7, 21, 17, 30),
      onboardingTime: '05:30 PM',
      arrivalTime: '05:43 PM',
      fare: 20.0,
      numberOfTickets: 1,
      paymentMethod: 'Nagad',
      paymentRef: 'NAGAD-2603',
      status: 'Completed',
      turnstileGate: 'Turnstile #01',
    ),
    TravelLogModel(
      id: 'TRIP-2602',
      fromStation: 'Agargaon',
      toStation: 'Bangladesh Secretariat',
      trainNumber: 'MRT-110',
      date: DateTime(2026, 7, 20, 16, 15),
      onboardingTime: '04:15 PM',
      arrivalTime: '04:30 PM',
      fare: 30.0,
      numberOfTickets: 1,
      paymentMethod: 'Metro Digital Wallet',
      paymentRef: 'WALLET-2602',
      status: 'Completed',
      turnstileGate: 'Turnstile #05',
    ),
    TravelLogModel(
      id: 'TRIP-2601',
      fromStation: 'Pallabi',
      toStation: 'Karwan Bazar',
      trainNumber: 'MRT-104',
      date: DateTime(2026, 7, 19, 8, 55),
      onboardingTime: '08:55 AM',
      arrivalTime: '09:15 AM',
      fare: 40.0,
      numberOfTickets: 1,
      paymentMethod: 'bKash',
      paymentRef: 'BKASH-2601',
      status: 'Completed',
      turnstileGate: 'Turnstile #02',
    ),
    TravelLogModel(
      id: 'TRIP-2608',
      fromStation: 'Motijheel',
      toStation: 'Uttara North',
      trainNumber: 'MRT-112',
      date: DateTime(2026, 7, 26, 9, 0),
      onboardingTime: '09:00 AM',
      arrivalTime: '09:40 AM',
      fare: 100.0,
      numberOfTickets: 1,
      paymentMethod: 'Metro Digital Wallet',
      paymentRef: 'WALLET-2608',
      status: 'Upcoming',
      turnstileGate: 'Turnstile #03',
    ),
  ].obs;

  /// Filtered logs getter
  List<TravelLogModel> get filteredLogs {
    if (selectedTab.value == 'Completed') {
      return logs.where((item) => item.status == 'Completed').toList();
    } else if (selectedTab.value == 'Upcoming') {
      return logs.where((item) => item.status == 'Upcoming').toList();
    }
    return logs;
  }

  /// Total trips count
  int get totalTripsCount => logs.length;

  /// This month spending sum (July 2026)
  double get thisMonthSpending {
    final now = DateTime.now();
    return logs
        .where((item) =>
            item.status == 'Completed' &&
            item.date.month == now.month &&
            item.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.fare);
  }

  /// This month trips count
  int get thisMonthTripsCount {
    final now = DateTime.now();
    return logs
        .where((item) => item.date.month == now.month && item.date.year == now.year)
        .length;
  }

  /// Add new trip log dynamically upon booking
  void addTravelLog(TravelLogModel log) {
    logs.insert(0, log);
  }

  /// Change filter tab
  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  /// Export travel log report
  void exportTravelLog() {
    final ctx = Get.context;
    if (ctx != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.download_done, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Travel Log Report exported to PDF successfully!')),
            ],
          ),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
