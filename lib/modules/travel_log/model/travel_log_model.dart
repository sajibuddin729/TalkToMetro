class TravelLogModel {
  final String id;
  final String fromStation;
  final String toStation;
  final String trainNumber;
  final DateTime date;
  final String onboardingTime;
  final String arrivalTime;
  final double fare;
  final int numberOfTickets;
  final String paymentMethod;
  final String paymentRef;
  final String status; // 'Completed', 'Upcoming', 'Cancelled'
  final String turnstileGate;

  TravelLogModel({
    required this.id,
    required this.fromStation,
    required this.toStation,
    required this.trainNumber,
    required this.date,
    required this.onboardingTime,
    required this.arrivalTime,
    required this.fare,
    required this.numberOfTickets,
    required this.paymentMethod,
    required this.paymentRef,
    required this.status,
    required this.turnstileGate,
  });
}
