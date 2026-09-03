import 'package:get/get.dart';
import 'package:mrts/login/Screens/Splash/splash.dart';
import 'package:mrts/modules/fare_info/view/fare_info_view.dart';
import 'package:mrts/modules/home/view/homepage.dart';
import 'package:mrts/modules/live_tracker/view/live_tracker_view.dart';
import 'package:mrts/modules/my_route/view/my_route_view.dart';
import 'package:mrts/modules/notification/view/notification_view.dart';
import 'package:mrts/modules/other_info/view/other_info_view.dart';
import 'package:mrts/modules/route/view/routes.dart';
import 'package:mrts/modules/settings/view/edit_profile_view.dart';
import 'package:mrts/modules/settings/view/help_center_view.dart';
import 'package:mrts/modules/settings/view/mrt_pass_view.dart';
import 'package:mrts/modules/settings/view/privacy_policy_view.dart';
import 'package:mrts/modules/settings/view/settings_view.dart';
import 'package:mrts/modules/time_table/view/time_table.dart';
import 'package:mrts/modules/travel_log/view/travel_log_view.dart';
import 'package:mrts/modules/wallet/view/wallet_view.dart';

class RouteHelper {
  static const String splashScreen = '/';

  static const String homeScreen = '/home';
  static const String myRoute = '/my-route';
  static const String fareInformation = '/fareInfo';
  static const String timeTableInformation = '/timeTable';
  static const String walletScreen = '/wallet';
  static const String metroMapScreen = '/metroMap';
  static const String otherInfoScreen = '/otherInfo';
  static const String settingsScreen = '/settings';
  static const String editProfileScreen = '/edit-profile';
  static const String mrtPassScreen = '/mrt-pass';
  static const String helpCenterScreen = '/help-center';
  static const String privacyPolicyScreen = '/privacy-policy';
  static const String notificationScreen = '/notifications';
  static const String liveTrackerScreen = '/live-tracker';
  static const String travelLogScreen = '/travel-log';

  static String getmySplashScreen() => splashScreen;
  static String getmyHomeScreen() => homeScreen;
  static String getmyRouteScreen() => myRoute;
  static String getfareInfoScreen() => fareInformation;
  static String gettimeTableScreen() => timeTableInformation;
  static String getwalletScreen() => walletScreen;
  static String getmetroMapScreen() => metroMapScreen;
  static String getotherInfoScreen() => otherInfoScreen;
  static String getSettingsScreen() => settingsScreen;
  static String getEditProfileScreen() => editProfileScreen;
  static String getMrtPassScreen() => mrtPassScreen;
  static String getHelpCenterScreen() => helpCenterScreen;
  static String getPrivacyPolicyScreen() => privacyPolicyScreen;
  static String getNotificationScreen() => notificationScreen;
  static String getLiveTrackerScreen() => liveTrackerScreen;
  static String getTravelLogScreen() => travelLogScreen;

  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: homeScreen, page: () => const HomePage()),
    GetPage(name: myRoute, page: () => const MyRoutesScreen()),
    GetPage(name: fareInformation, page: () => const FareInfoScreen()),
    GetPage(name: timeTableInformation, page: () => const TimeTableScreen()),
    GetPage(name: walletScreen, page: () => const WalletScreen()),
    GetPage(name: metroMapScreen, page: () => const RoutesScreen()),
    GetPage(name: otherInfoScreen, page: () => const OtherInfoScreen()),
    GetPage(name: settingsScreen, page: () => const SettingsView()),
    GetPage(name: editProfileScreen, page: () => const EditProfileView()),
    GetPage(name: mrtPassScreen, page: () => const MrtPassView()),
    GetPage(name: helpCenterScreen, page: () => const HelpCenterView()),
    GetPage(name: privacyPolicyScreen, page: () => const PrivacyPolicyView()),
    GetPage(name: notificationScreen, page: () => const NotificationView()),
    GetPage(name: liveTrackerScreen, page: () => const LiveTrackerView()),
    GetPage(name: travelLogScreen, page: () => const TravelLogView()),
  ];
}
