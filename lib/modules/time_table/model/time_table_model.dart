class TimeTableCategory {
  final String trainNo;
  final String start;
  final String des;
  final String time;
  final String destime;
  final String direction;
  final String taka; // Frequency / Status
  final String slot; // Morning, Afternoon, Evening
  final int totalDurationMin;

  TimeTableCategory({
    required this.trainNo,
    required this.start,
    required this.des,
    required this.time,
    required this.destime,
    required this.direction,
    required this.taka,
    required this.slot,
    required this.totalDurationMin,
  });
}