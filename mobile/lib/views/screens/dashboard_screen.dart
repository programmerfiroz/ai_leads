import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/lead_controller.dart';
import 'lead_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LeadController controller = Get.find<LeadController>();
    final AuthController authController = Get.find<AuthController>();
    final user = GetStorage().read('user') ?? {};

    return Scaffold(
      appBar: AppBar(
        title: null,
        toolbarHeight: 20,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshLeads(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
                ),
                Text(
                  '${user['name'] ?? 'User'}!',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    '${user['organization_name'] ?? 'AI Lead CRM'} • ${user['business_category'] ?? 'Business'}',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Business Performance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Obx(() => GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard('Total Leads', controller.stats['total']?.toString() ?? '0', Colors.blue),
                    _buildStatCard('New Leads', controller.stats['new']?.toString() ?? '0', Colors.orange),
                    _buildStatCard('Contacted', controller.stats['contacted']?.toString() ?? '0', Colors.purple),
                    _buildStatCard('Converted', controller.stats['converted']?.toString() ?? '0', Colors.green),
                  ],
                )),
                const SizedBox(height: 30),
                // Featured Card for Scraper
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Theme.of(context).primaryColor, const Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                      const SizedBox(height: 15),
                      const Text(
                        'Ready for new leads?',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Start a new scrape run from the Scrape tab to find more businesses.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100), // Spacing for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.white60)),
            const SizedBox(height: 5),
            Text(count, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _showScrapeDialog(BuildContext context, LeadController controller) {
    final keywordController = TextEditingController();
    final locationController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Start Scraping'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: keywordController, decoration: const InputDecoration(hintText: 'Keyword (e.g. Restaurants)')),
            const SizedBox(height: 10),
            TextField(controller: locationController, decoration: const InputDecoration(hintText: 'Location (e.g. Lucknow)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Trigger API call to backend (omitted for brevity, but controller has the structure)
              Get.back();
              Get.snackbar('Processing', 'Lead scraping started in background');
            },
            child: const Text('Scrape'),
          ),
        ],
      ),
    );
  }
}
