import 'package:get/get.dart';
import 'package:mrts/modules/home/model/home_category.dart';
import 'package:mrts/utils/images.dart';

class HomeController extends GetxController implements GetxService {
  HomeController();
  List<HomeCategory>? _homecategory;
  List<HomeCategory>? get homecategory => _homecategory;

  Future<void> getData() async {
    _homecategory = [
      HomeCategory(
        name: "My Routes",
        image: Images.route,
      ),
      HomeCategory(
        name: "Fare Info",
        image: Images.currency,
      ),
      HomeCategory(
        name: "Time Table",
        image: Images.train,
      ),
      HomeCategory(
        name: "Wallet",
        image: Images.wallet,
      ),
      HomeCategory(
        name: "Live Tracker",
        image: Images.map,
      ),
      HomeCategory(
        name: "Other Info",
        image: Images.vector,
      ),
    ];
    update();
  }
}