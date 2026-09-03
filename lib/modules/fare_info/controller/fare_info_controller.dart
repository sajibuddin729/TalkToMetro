import 'package:get/get.dart';
import 'package:mrts/data/metro_stations.dart';
import 'package:mrts/modules/fare_info/model/fare_info_model.dart';
import 'package:mrts/utils/images.dart';

class FareInfoController extends GetxController implements GetxService {
  List<FareInfoCategory>? _farecategory;
  List<FareInfoCategory>? get farecategory => _farecategory;

  final calcFromStation = 'Uttara North'.obs;
  final calcToStation = 'Motijheel'.obs;
  final calculatedSingleFare = 100.obs;
  final calculatedMrtFare = 90.obs;
  final calculatedDistance = 15.obs;

  @override
  void onInit() {
    super.onInit();
    getData();
    calculateFare();
  }

  Future<void> getData() async {
    final stations = metroStationNames;
    final list = <FareInfoCategory>[];

    for (int i = 0; i < stations.length; i++) {
      for (int j = i + 1; j < stations.length; j++) {
        final dist = (j - i).abs();
        final singleFare = computeFare(dist);
        final mrtFare = (singleFare * 0.9).round();

        list.add(
          FareInfoCategory(
            image: Images.homelogo,
            taka: '৳ $singleFare',
            mrtPassFare: '৳ $mrtFare',
            start: stations[i],
            des: stations[j],
            stationDistance: dist,
          ),
        );
      }
    }

    _farecategory = list;
    update();
  }

  static int computeFare(int stationDistance) {
    if (stationDistance <= 0) return 0;
    if (stationDistance <= 2) return 20;
    if (stationDistance <= 4) return 30;
    if (stationDistance <= 6) return 40;
    if (stationDistance <= 8) return 50;
    if (stationDistance <= 10) return 60;
    if (stationDistance <= 12) return 70;
    if (stationDistance <= 14) return 80;
    if (stationDistance <= 15) return 90;
    return 100; // max fare for line 6
  }

  void calculateFare() {
    final fromIdx = metroStationNames.indexOf(calcFromStation.value);
    final toIdx = metroStationNames.indexOf(calcToStation.value);

    if (fromIdx == -1 || toIdx == -1 || fromIdx == toIdx) {
      calculatedDistance.value = 0;
      calculatedSingleFare.value = 0;
      calculatedMrtFare.value = 0;
      return;
    }

    final dist = (toIdx - fromIdx).abs();
    final singleFare = computeFare(dist);
    final mrtFare = (singleFare * 0.9).round();

    calculatedDistance.value = dist;
    calculatedSingleFare.value = singleFare;
    calculatedMrtFare.value = mrtFare;
    update();
  }
}