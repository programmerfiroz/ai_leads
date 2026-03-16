import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lead_controller.dart';
import '../../controllers/nav_controller.dart';

class ScrapeScreen extends StatelessWidget {
  const ScrapeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LeadController controller = Get.find<LeadController>();
    final keywordController = TextEditingController();
    final locationController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Scraping'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 32),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Powered Scraper', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('Generate high-quality leads from Google Maps instantly.', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('What are you looking for?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: keywordController,
              decoration: InputDecoration(
                hintText: 'e.g. Restaurants, Gyms, Bakeries',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Where should we search?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'e.g. Lucknow, Noida, Dubai',
                prefixIcon: const Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : () {
                  if (keywordController.text.isEmpty || locationController.text.isEmpty) {
                    Get.snackbar('Error', 'Please fill all fields');
                    return;
                  }
                  controller.scrapeLeads(keywordController.text, locationController.text).then((_) {
                    Get.find<NavController>().changeIndex(1); // Navigate to Leads tab
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: controller.isLoading.value 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Initiate Scrape Run', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )),
            ),
            const SizedBox(height: 30),
            const Text('Pro Tips 💡', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 8),
            const Text('• Use specific keywords for better results.\n• The scraper works in the background even if you close the app.\n• New leads will appear in your "Leads" tab once synced.', 
              style: TextStyle(fontSize: 12, color: Colors.white60, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
