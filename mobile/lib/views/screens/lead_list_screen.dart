import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lead_controller.dart';
import '../../models/lead_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import 'lead_detail_screen.dart';
import 'lead_form_screen.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  Timer? _refreshTimer;
  final LeadController controller = Get.find<LeadController>();
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Auto-refresh every 10 seconds to show real-time scraped leads
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (searchController.text.isEmpty) {
        controller.fetchLeads();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1, size: 22, color: Colors.blueAccent),
            tooltip: 'Save all to Contacts',
            onPressed: () => controller.bulkSaveToContacts(),
          ),
          IconButton(
            icon: const Icon(Icons.sync, size: 20),
            onPressed: () => controller.refreshLeads(),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: searchController,
              onChanged: (val) => controller.fetchLeads(search: val),
              decoration: InputDecoration(
                hintText: 'Search Businesses...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
          ),
          _buildSummaryStats(),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null, controller),
                _buildFilterChip('New', 'New', controller),
                _buildFilterChip('Contacted', 'Contacted', controller),
                _buildFilterChip('Interested', 'Interested', controller),
                _buildFilterChip('Converted', 'Converted', controller),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.leads.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.leads.isEmpty) {
                return const Center(child: Text('No leads found'));
              }
              return RefreshIndicator(
                onRefresh: () => controller.refreshLeads(),
                child: ListView.builder(
                  itemCount: controller.leads.length,
                  itemBuilder: (context, index) {
                    final lead = controller.leads[index];
                    return _buildLeadCard(context, lead);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const LeadFormScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryStats() {
    return Obx(() {
      final total = controller.leads.length;
      final newLeads = controller.leads.where((l) => l.status == 'New' && !l.isViewed).length;
      final contacted = controller.leads.where((l) => l.status == 'Contacted' || (l.status == 'New' && l.isViewed)).length;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        height: 60,
        child: Row(
          children: [
            _buildSummaryItem('Total', total.toString(), Colors.blue),
            const SizedBox(width: 10),
            _buildSummaryItem('New', newLeads.toString(), Colors.orange),
            const SizedBox(width: 10),
            _buildSummaryItem('Follow-up', contacted.toString(), Colors.purple),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status, LeadController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: FilterChip(
        label: Text(label),
        onSelected: (val) => controller.fetchLeads(status: status),
        backgroundColor: Colors.white10,
        selectedColor: Get.theme.primaryColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, Lead lead) {
    bool hasContactInfo = lead.phone != null && lead.phone!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      elevation: 0,
      color: Colors.white.withOpacity(0.03),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              controller.markAsViewed(lead);
              Get.to(() => LeadDetailScreen(lead: lead));
            },
            contentPadding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    lead.businessName, 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: lead.isViewed ? Colors.white38 : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (lead.rating != null && lead.rating != 'N/A') ...[
                  const SizedBox(width: 8),
                  Icon(Icons.star_rounded, color: Colors.orange.shade400, size: 16),
                  const SizedBox(width: 2),
                  Text(lead.rating!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.category_outlined, size: 12, color: lead.isViewed ? Colors.white12 : Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      lead.category ?? 'Business', 
                      style: TextStyle(color: lead.isViewed ? Colors.white12 : Colors.white38, fontSize: 12)
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.location_on_outlined, size: 12, color: lead.isViewed ? Colors.white12 : Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      lead.city ?? 'Local', 
                      style: TextStyle(color: lead.isViewed ? Colors.white12 : Colors.white38, fontSize: 12)
                    ),
                  ],
                ),
              ],
            ),
            trailing: InkWell(
              onTap: () => _showStatusUpdateDialog(context, lead),
              borderRadius: BorderRadius.circular(8),
              child: (lead.status == 'New' && lead.isViewed) 
                ? const Icon(Icons.edit_note, size: 20, color: Colors.white24)
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(lead.status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lead.status,
                      style: TextStyle(color: _getStatusColor(lead.status), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Divider(color: Colors.white.withOpacity(0.05), height: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildQuickAction(
                      icon: Icons.phone_outlined, 
                      color: Colors.blue, 
                      onTap: hasContactInfo ? () {
                        final phone = lead.phone!.replaceAll(RegExp(r'\D'), '');
                        _launchURL('tel:$phone');
                      } : null,
                      isActive: hasContactInfo,
                    ),
                    _buildQuickAction(
                      icon: Icons.chat_outlined, 
                      color: Colors.green, 
                      onTap: hasContactInfo ? () => _launchWhatsApp(lead) : null,
                      isActive: hasContactInfo,
                    ),
                    _buildQuickAction(
                      icon: Icons.map_outlined, 
                      color: Colors.orange, 
                      onTap: (lead.mapsLink != null && lead.mapsLink!.isNotEmpty) ? () => _launchURL(lead.mapsLink!) : null,
                      isActive: (lead.mapsLink != null && lead.mapsLink!.isNotEmpty),
                    ),
                    _buildQuickAction(
                      icon: Icons.email_outlined, 
                      color: Colors.redAccent, 
                      onTap: (lead.email != null && lead.email!.isNotEmpty) ? () => _launchURL('mailto:${lead.email}') : null,
                      isActive: (lead.email != null && lead.email!.isNotEmpty),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (lead.isSavedLocally)
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Added', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      )
                    else
                      TextButton.icon(
                        onPressed: hasContactInfo ? () => controller.saveLeadToContacts(lead) : null,
                        icon: Icon(
                          Icons.person_add_outlined, 
                          size: 18,
                          color: hasContactInfo ? Colors.blueAccent : Colors.white10,
                        ),
                        label: Text(
                          'Save', 
                          style: TextStyle(
                            fontSize: 12,
                            color: hasContactInfo ? Colors.blueAccent : Colors.white10,
                          )
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required Color color, VoidCallback? onTap, bool isActive = true}) {
    return IconButton(
      icon: Icon(icon, color: isActive ? color.withOpacity(0.8) : Colors.white10),
      onPressed: onTap,
      splashRadius: 20,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }

  void _launchWhatsApp(Lead lead) async {
    final user = GetStorage().read('user') ?? {};
    final myOrg = user['organization_name'] ?? 'my company';
    final myName = user['name'] ?? 'me';
    
    String message;
    if (lead.aiPitch != null && lead.aiPitch!.isNotEmpty) {
      message = "Hi ${lead.businessName},\n\n${lead.aiPitch}\n\n- $myName from $myOrg";
    } else {
      message = "Hi ${lead.businessName},\n\n"
          "I'm $myName from $myOrg. I noticed your ${lead.category ?? 'business'} in ${lead.city ?? 'your area'} and wanted to share how our AI tools can help you automate and scale.\n\n"
          "Specifically, we can help ${lead.businessName} with:\n"
          "✅ AI-Driven Customer Engagement\n"
          "✅ Smart GMB Optimization\n"
          "✅ 24/7 Autopilot Support\n\n"
          "Would you be open to a 2-minute chat about transforming your ${lead.category ?? 'business'} with AI?";
    }
    
    final encodedMsg = Uri.encodeComponent(message);
    final normalizedPhone = lead.phone!.replaceAll(RegExp(r'\D'), '');
    final url = "https://wa.me/$normalizedPhone?text=$encodedMsg";
    _launchURL(url);
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showStatusUpdateDialog(BuildContext context, Lead lead) {
    String selectedStatus = lead.status;
    final notesController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedStatus,
              items: ['New', 'Contacted', 'Interested', 'Not Interested', 'Converted']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => selectedStatus = val!,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 10),
            TextField(controller: notesController, decoration: const InputDecoration(labelText: 'Notes')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.updateLeadStatus(lead.id!, selectedStatus, notes: notesController.text);
              Get.back();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New': return Colors.blue;
      case 'Contacted': return Colors.purple;
      case 'Interested': return Colors.orange;
      case 'Converted': return Colors.green;
      case 'Not Interested': return Colors.red;
      default: return Colors.grey;
    }
  }
}
