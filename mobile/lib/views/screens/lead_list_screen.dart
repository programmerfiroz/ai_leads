import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lead_controller.dart';
import '../../models/lead_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Business Leads',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.8,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF0F172A)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'add') Get.to(() => const LeadFormScreen());
              if (value == 'save') controller.bulkSaveToContacts();
              if (value == 'sync') controller.refreshLeads();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF056E73)),
                    SizedBox(width: 12),
                    Text('Add Manual Lead', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.person_add_alt_1_rounded, size: 18, color: Color(0xFF3B82F6)),
                    SizedBox(width: 12),
                    Text('Save All Contacts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync_rounded, size: 18, color: Color(0xFF10B981)),
                    SizedBox(width: 12),
                    Text('Sync Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Sleek Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (val) => controller.fetchLeads(search: val),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Search leads...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.2), fontWeight: FontWeight.w500),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.black.withOpacity(0.2), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ),
          
          _buildSummaryStats(),
          const SizedBox(height: 15),
          
          // Refined Filter Chips
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                _buildFilterChip('All', null, controller),
                _buildFilterChip('New', 'New', controller),
                _buildFilterChip('Contacted', 'Contacted', controller),
                _buildFilterChip('Interested', 'Interested', controller),
                _buildFilterChip('Converted', 'Converted', controller),
              ],
            ),
          )),
          const SizedBox(height: 10),
          
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.leads.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF056E73).withOpacity(0.8),
                    strokeWidth: 2,
                  ),
                );
              }
              if (controller.leads.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.black.withOpacity(0.05)),
                      const SizedBox(height: 16),
                      Text(
                        'No business leads found',
                        style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => controller.refreshLeads(),
                color: const Color(0xFF056E73),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10, bottom: 100),
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
    );
  }

  Widget _buildSummaryStats() {
    return Obx(() {
      final total = controller.leads.length;
      final newLeads = controller.leads.where((l) => l.status == 'New' && !l.isViewed).length;
      final contacted = controller.leads.where((l) => l.status == 'Contacted' || (l.status == 'New' && l.isViewed)).length;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildSummaryItem('TOTAL', total.toString(), const Color(0xFF056E73)),
            const SizedBox(width: 10),
            _buildSummaryItem('NEW', newLeads.toString(), const Color(0xFFF59E0B)),
            const SizedBox(width: 10),
            _buildSummaryItem('FOLLOW-UP', contacted.toString(), const Color(0xFF6366F1)),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              value, 
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5)
            ),
            const SizedBox(height: 2),
            Text(
              label, 
              style: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w800, fontSize: 9, letterSpacing: 0.8)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status, LeadController controller) {
    bool isSelected = (status == null && controller.selectedStatus.value == null) || 
                     (status == controller.selectedStatus.value);
    
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () => controller.fetchLeads(status: status),
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF056E73) : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: isSelected ? const Color(0xFF056E73) : Colors.black.withOpacity(0.04)),
            boxShadow: isSelected ? [
              BoxShadow(
                color: const Color(0xFF056E73).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isSelected ? Colors.white : Colors.black38,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadCard(BuildContext context, Lead lead) {
    bool hasContactInfo = lead.phone != null && lead.phone!.isNotEmpty;
    bool isNew = !lead.isViewed;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle Status-based Accent
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              color: _getStatusColor(lead.status).withOpacity(0.8),
            ),
          ),
          
          Column(
            children: [
              ListTile(
                onTap: () {
                  controller.markAsViewed(lead);
                  Get.to(() => LeadDetailScreen(lead: lead));
                },
                contentPadding: const EdgeInsets.fromLTRB(24, 20, 20, 8),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        lead.businessName, 
                        style: TextStyle(
                          fontWeight: FontWeight.w800, 
                          fontSize: 16,
                          color: const Color(0xFF0F172A).withOpacity(lead.isViewed ? 0.8 : 1.0),
                          letterSpacing: -0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (lead.rating != null && lead.rating != 'N/A') ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                      const SizedBox(width: 2),
                      Text(
                        lead.rating!, 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))
                      ),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.category_rounded, size: 10, color: Colors.black.withOpacity(0.4)),
                              const SizedBox(width: 4),
                              Text(
                                lead.category ?? 'Business', 
                                style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w700)
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 10, color: Colors.black.withOpacity(0.4)),
                              const SizedBox(width: 4),
                              Text(
                                lead.city ?? 'Local', 
                                style: TextStyle(color: Colors.black.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w700)
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(lead.status).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    lead.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(lead.status), 
                      fontSize: 9, 
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildQuickAction(
                          icon: Icons.phone_rounded, 
                          color: const Color(0xFF3B82F6), 
                          onTap: hasContactInfo ? () {
                            final phone = lead.phone!.replaceAll(RegExp(r'\D'), '');
                            _launchURL('tel:$phone');
                          } : null,
                          isActive: hasContactInfo,
                        ),
                        _buildQuickAction(
                          icon: FontAwesomeIcons.whatsapp, 
                          color: const Color(0xFF25D366), 
                          onTap: hasContactInfo ? () => _launchWhatsApp(lead) : null,
                          isActive: hasContactInfo,
                          isFontAwesome: true,
                        ),
                        _buildQuickAction(
                          icon: Icons.map_rounded, 
                          color: const Color(0xFFF59E0B), 
                          onTap: (lead.mapsLink != null && lead.mapsLink!.isNotEmpty) ? () => _launchURL(lead.mapsLink!) : null,
                          isActive: (lead.mapsLink != null && lead.mapsLink!.isNotEmpty),
                        ),
                        _buildQuickAction(
                          icon: Icons.email_rounded, 
                          color: const Color(0xFFEF4444), 
                          onTap: (lead.email != null && lead.email!.isNotEmpty) ? () => _launchURL('mailto:${lead.email}') : null,
                          isActive: (lead.email != null && lead.email!.isNotEmpty),
                        ),
                      ],
                    ),
                    
                    if (lead.isSavedLocally)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_rounded, color: const Color(0xFF10B981), size: 14),
                            const SizedBox(width: 4),
                            const Text(
                              'SAVED', 
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)
                            ),
                          ],
                        ),
                      )
                    else
                      InkWell(
                        onTap: hasContactInfo ? () => controller.saveLeadToContacts(lead) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: hasContactInfo ? const Color(0xFF056E73).withOpacity(0.05) : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: hasContactInfo ? const Color(0xFF056E73).withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_add_rounded, 
                                size: 14,
                                color: hasContactInfo ? const Color(0xFF056E73) : Colors.black12,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'SAVE', 
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: hasContactInfo ? const Color(0xFF056E73) : Colors.black12,
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({required dynamic icon, required Color color, VoidCallback? onTap, bool isActive = true, bool isFontAwesome = false}) {
    return IconButton(
      icon: isFontAwesome 
        ? FaIcon(icon, color: isActive ? color : Colors.black.withOpacity(0.05), size: 18)
        : Icon(icon, color: isActive ? color : Colors.black.withOpacity(0.05)),
      onPressed: onTap,
      splashRadius: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 44),
      iconSize: 20,
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
    try {
      // Try direct launch first as canLaunchUrl can be flaky on some Android versions
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        Get.snackbar(
          'Notice', 
          'Could not open the link directly. Make sure the app is installed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
      }
    } catch (e) {
      debugPrint('Launch error: $e');
      Get.snackbar(
        'Launch Error', 
        'Unable to open this type of link.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void _showStatusUpdateDialog(BuildContext context, Lead lead) {
    String selectedStatus = lead.status;
    final notesController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Interaction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
            ),
            const SizedBox(height: 30),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              items: ['New', 'Contacted', 'Interested', 'Not Interested', 'Converted']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => selectedStatus = val!,
              decoration: InputDecoration(
                labelText: 'Engagement Stage',
                labelStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: notesController, 
              decoration: InputDecoration(
                labelText: 'Quick Notes',
                labelStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w600),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              )
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  controller.updateLeadStatus(lead.id!, selectedStatus, notes: notesController.text);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF056E73),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Update', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New': return const Color(0xFF3B82F6);
      case 'Contacted': return const Color(0xFF8B5CF6);
      case 'Interested': return const Color(0xFFF59E0B);
      case 'Converted': return const Color(0xFF10B981);
      case 'Not Interested': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }
}
