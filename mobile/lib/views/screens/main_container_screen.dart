import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dashboard_screen.dart';
import 'lead_list_screen.dart';
import 'profile_screen.dart';
import 'scrape_screen.dart';
import 'history_screen.dart';
import '../../controllers/nav_controller.dart';

class MainContainerScreen extends StatelessWidget {
  const MainContainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavController navController = Get.find<NavController>();

    final List<Widget> screens = [
      const DashboardScreen(),
      LeadListScreen(),
      const ScrapeScreen(),
      const HistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() => IndexedStack(
        index: navController.selectedIndex.value,
        children: screens,
      )),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Obx(() => BottomNavigationBar(
          currentIndex: navController.selectedIndex.value,
          onTap: (index) => navController.changeIndex(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Leads',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'Scrape',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history_toggle_off),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        )),
      ),
    );
  }
}
