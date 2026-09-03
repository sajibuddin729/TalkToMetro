import 'package:get/get.dart';

class MetroNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type; // 'alert', 'ticket', 'recharge', 'schedule'
  bool isRead;

  MetroNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class NotificationController extends GetxController implements GetxService {
  final notifications = <MetroNotification>[
    MetroNotification(
      id: 'N-1',
      title: 'MRT Pass Recharge Successful',
      message: '৳500 has been added to your MRT Pass (MRT-88392011) via bKash.',
      time: '10 mins ago',
      type: 'recharge',
      isRead: false,
    ),
    MetroNotification(
      id: 'N-2',
      title: 'Peak Hour Schedule Update',
      message: 'Dhaka Metro Line 6 train frequency increased to 6-minute intervals during peak hours (8 AM – 11 AM).',
      time: '2 hours ago',
      type: 'schedule',
      isRead: false,
    ),
    MetroNotification(
      id: 'N-3',
      title: 'Ticket Booking Confirmed',
      message: 'Single Journey Ticket from Uttara North to Motijheel (1 Passenger, ৳100) confirmed.',
      time: 'Yesterday, 04:15 PM',
      type: 'ticket',
      isRead: true,
    ),
    MetroNotification(
      id: 'N-4',
      title: 'Service Announcement',
      message: 'All 16 stations from Uttara North to Motijheel are fully operational.',
      time: '20 Jul 2026',
      type: 'alert',
      isRead: true,
    ),
  ].obs;

  void markAllAsRead() {
    for (var item in notifications) {
      item.isRead = true;
    }
    notifications.refresh();
  }

  void clearAll() {
    notifications.clear();
  }
}
