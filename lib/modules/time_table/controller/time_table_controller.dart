import 'package:get/get.dart';
import 'package:mrts/data/metro_stations.dart';
import 'package:mrts/modules/time_table/model/time_table_model.dart';

class TimeTableController extends GetxController implements GetxService {
  final selectedOrigin = 'Uttara North'.obs;
  final selectedDestination = 'Motijheel'.obs;
  final selectedDirection = 'All'.obs; // 'All', 'Southbound', 'Northbound'
  final selectedSlot = 'All Day'.obs; // 'All Day', 'Morning', 'Afternoon', 'Evening'

  final fullSchedule = <TimeTableCategory>[].obs;
  final filteredSchedule = <TimeTableCategory>[].obs;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> getData() async {
    generateSchedule();
  }

  void swapStations() {
    final temp = selectedOrigin.value;
    selectedOrigin.value = selectedDestination.value;
    selectedDestination.value = temp;
    generateSchedule();
  }

  void generateSchedule() {
    final origin = selectedOrigin.value;
    final dest = selectedDestination.value;
    final stations = metroStationNames;

    final origIdx = stations.indexOf(origin);
    final destIdx = stations.indexOf(dest);

    final generated = <TimeTableCategory>[];

    if (origIdx == -1 || destIdx == -1 || origIdx == destIdx) {
      filteredSchedule.clear();
      fullSchedule.clear();
      update();
      return;
    }

    final isSouthbound = origIdx < destIdx;
    final directionStr = isSouthbound ? 'Southbound' : 'Northbound';
    final stationCount = (destIdx - origIdx).abs();
    final travelMinutes = (stationCount * 2.2).round(); // ~2.2 mins per stop

    // Operating hours: 6:30 AM (390 min) to 10:10 PM (1330 min)
    int currentMin = 6 * 60 + 30; // 06:30 AM
    final endMin = 22 * 60 + 10; // 10:10 PM
    int trainCounter = isSouthbound ? 101 : 201;

    while (currentMin <= endMin) {
      // Determine frequency & peak slot based on current time
      final hour = currentMin ~/ 60;
      int stepMin = 8; // Default off-peak
      String takaLabel = 'Freq: 8 min';

      if ((hour >= 8 && hour < 11) || (hour >= 15 && hour < 20)) {
        stepMin = 6; // Peak hour
        takaLabel = 'Peak (6 min)';
      } else if (hour >= 20) {
        stepMin = 12; // Late night
        takaLabel = 'Night (12 min)';
      }

      String slot;
      if (hour < 12) {
        slot = 'Morning';
      } else if (hour < 17) {
        slot = 'Afternoon';
      } else {
        slot = 'Evening';
      }

      final depTimeStr = _formatMinutes(currentMin);
      final arrTimeStr = _formatMinutes(currentMin + travelMinutes);

      generated.add(
        TimeTableCategory(
          trainNo: 'MRT-${trainCounter++}',
          start: origin,
          des: dest,
          time: depTimeStr,
          destime: arrTimeStr,
          direction: directionStr,
          taka: takaLabel,
          slot: slot,
          totalDurationMin: travelMinutes,
        ),
      );

      currentMin += stepMin;
    }

    fullSchedule.assignAll(generated);
    applyFilter();
  }

  void applyFilter() {
    final dir = selectedDirection.value;
    final slot = selectedSlot.value;

    final filtered = fullSchedule.where((item) {
      final matchesDir = (dir == 'All') || (item.direction == dir);
      final matchesSlot = (slot == 'All Day') || (item.slot == slot);
      return matchesDir && matchesSlot;
    }).toList();

    filteredSchedule.assignAll(filtered);
    update();
  }

  String _formatMinutes(int totalMinutes) {
    final hour = (totalMinutes ~/ 60) % 24;
    final min = totalMinutes % 60;
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final formattedMin = min < 10 ? '0$min' : '$min';
    return '$formattedHour:$formattedMin $period';
  }
}