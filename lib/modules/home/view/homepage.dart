import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mrts/modules/home/controller/home_controller.dart';
import 'package:mrts/modules/home/widget/metro_list.dart';
import 'package:mrts/modules/home/widget/nearby_stations_widget.dart';
import 'package:mrts/modules/home/widget/top_section.dart';
import 'package:mrts/modules/route/view/routes.dart';
import 'package:mrts/modules/settings/controller/settings_controller.dart';
import 'package:mrts/modules/settings/view/settings_view.dart';
import 'package:mrts/routes/route_helper.dart';
import 'package:mrts/utils/dimensions.dart';
import 'package:mrts/utils/images.dart';
import 'package:mrts/utils/style.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final HomeController homeController;

  @override
  void initState() {
    super.initState();
    homeController = Get.put(HomeController());
    // Ensure SettingsController is alive for the whole app session
    if (!Get.isRegistered<SettingsController>()) {
      Get.put(SettingsController());
    }
  }

  /// Pages hosted inside the persistent bottom nav scaffold
  late final List<Widget> _pages = [
    const _HomeBody(),
    const RoutesScreen(),
    const SettingsView(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.grey.shade500,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: ubuntuBold.copyWith(
              fontSize: 10.sp, color: Colors.green.shade700),
          unselectedLabelStyle: ubuntuRegular.copyWith(
              fontSize: 10.sp, color: Colors.grey.shade500),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24.r),
              activeIcon:
                  Icon(Icons.home, size: 24.r, color: Colors.green.shade700),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined, size: 24.r),
              activeIcon:
                  Icon(Icons.map, size: 24.r, color: Colors.green.shade700),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 24.r),
              activeIcon: Icon(Icons.settings,
                  size: 24.r, color: Colors.green.shade700),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

/// The actual home body content, extracted to a separate widget
/// so IndexedStack can manage its lifecycle
class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBF3F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBF3F1),
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 10.w, top: 10.h),
          child: GestureDetector(
            onTap: () => Get.toNamed(RouteHelper.getSettingsScreen()),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Image.asset('images/menu.png', scale: 3),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w, top: 10.h),
            child: GestureDetector(
              onTap: () => Get.toNamed(RouteHelper.getNotificationScreen()),
              child: Image.asset(Images.notification, scale: 2),
            ),
          ),
        ],
        title: Padding(
          padding: EdgeInsets.only(right: 10.w, top: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(Images.homelogo, scale: 2),
              SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'Talk2Metro',
                style: ubuntuRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
            const TopSections(),
            SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
            const MetroList(),
            SizedBox(height: 20.h),
            // ── Nearby Stations ─────────────────────────
            const NearbyStationsWidget(),
            SizedBox(height: Dimensions.paddingSizeLarge),
          ],
        ),
      ),
    );
  }
}
