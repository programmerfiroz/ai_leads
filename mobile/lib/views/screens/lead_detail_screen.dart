import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../models/lead_model.dart';
import 'lead_form_screen.dart';
import '../../controllers/lead_controller.dart';

class LeadDetailScreen extends StatelessWidget {
  final Lead lead;
  const LeadDetailScreen({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final LeadController controller = Get.find<LeadController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Lead Details',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF056E73), size: 22),
            onPressed: () => Get.to(() => LeadFormScreen(lead: lead)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444), size: 22),
            onPressed: () => _confirmDelete(context, controller),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final currentLead = controller.leads.firstWhere((l) => l.id == lead.id, orElse: () => lead);
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(currentLead),
              _buildActionButtons(controller, currentLead),
              _buildPerformanceStats(currentLead),
              _buildSectionTitle('Lead Information'),
              _buildContactSection(currentLead),
              _buildSectionTitle('Ai Business Analysis'),
              _buildPitchSuggestions(currentLead),
              _buildSectionTitle('Social Presence'),
              _buildSocialSection(currentLead),
              _buildSectionTitle('Location'),
              _buildAddressSection(currentLead),
              const SizedBox(height: 50),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black.withOpacity(0.3), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildPitchSuggestions(Lead currentLead) {
    final hasAiPitch = currentLead.aiPitch != null && currentLead.aiPitch!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: Color(0xFFF59E0B), size: 18),
              const SizedBox(width: 10),
              const Text('Suggested Pitch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 16),
          if (hasAiPitch)
            Text(
              currentLead.aiPitch!,
              style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF334155), fontWeight: FontWeight.w500),
            )
          else ...[
            _buildPitchItem('Personalize', 'Mention their business name and local presence.'),
            _buildPitchItem('Optimize', 'Offer GMB profile and website optimization.'),
          ],
        ],
      ),
    );
  }

  Widget _buildPitchItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 16, color: Color(0xFFF59E0B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                Text(description, style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.4))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Lead currentLead) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF056E73).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.business_rounded, size: 32, color: Color(0xFF056E73)),
          ),
          const SizedBox(height: 16),
          Text(
            currentLead.businessName, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            currentLead.category ?? 'Business Category', 
            style: TextStyle(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _showStatusUpdateDialog(Get.context!, Get.find<LeadController>()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(currentLead.status).withOpacity(0.08), 
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _getStatusColor(currentLead.status).withOpacity(0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentLead.status.toUpperCase(), 
                    style: TextStyle(color: _getStatusColor(currentLead.status), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.8),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.edit_note_rounded, size: 14, color: _getStatusColor(currentLead.status)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats(Lead currentLead) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.star_rounded, currentLead.rating ?? 'N/A', 'Rating', const Color(0xFFF59E0B)),
          _buildStatDivider(),
          _buildStatItem(Icons.comment_rounded, currentLead.reviewsCount ?? '0', 'Reviews', const Color(0xFF3B82F6)),
          _buildStatDivider(),
          _buildStatItem(Icons.access_time_filled_rounded, currentLead.openingHours != null && currentLead.openingHours!.length > 5 ? 'Open' : 'N/A', 'Hours', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 24, width: 1, color: Colors.black.withOpacity(0.05));
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.3)),
        ),
      ],
    );
  }

  Widget _buildContactSection(Lead currentLead) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildInfoTile(Icons.person_rounded, 'Key Contact', currentLead.ownerName ?? 'Manager'),
          _buildInfoTile(Icons.phone_rounded, 'Phone', currentLead.phone ?? 'Not Provided'),
          _buildInfoTile(Icons.email_rounded, 'Email', currentLead.email ?? 'Not Provided'),
          _buildInfoTile(Icons.language_rounded, 'Website', currentLead.website ?? 'No Website'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF056E73), size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.black.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(LeadController controller, Lead currentLead) {
    final hasPhone = currentLead.phone != null && currentLead.phone!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(Icons.phone_rounded, 'Call', const Color(0xFF3B82F6), hasPhone ? () {
            final phone = currentLead.phone!.replaceAll(RegExp(r'\D'), '');
            _launchURL('tel:$phone');
          } : null),
          _buildActionButton(FontAwesomeIcons.whatsapp, 'WhatsApp', const Color(0xFF25D366), hasPhone ? () => _launchWhatsApp(currentLead) : null),
          _buildActionButton(Icons.map_rounded, 'Maps', const Color(0xFFF59E0B), (currentLead.mapsLink != null) ? () => _launchURL(currentLead.mapsLink!) : null),
          _buildActionButton(
            currentLead.isSavedLocally ? Icons.verified_rounded : Icons.person_add_rounded, 
            currentLead.isSavedLocally ? 'Saved' : 'Save', 
            const Color(0xFF10B981), 
            hasPhone && !currentLead.isSavedLocally ? () => controller.saveLeadToContacts(currentLead) : null
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(dynamic icon, String label, Color color, VoidCallback? onTap) {
    bool isActive = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive ? color.withOpacity(0.08) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isActive ? color.withOpacity(0.12) : Colors.black.withOpacity(0.05)),
            ),
            child: Center(
              child: icon is IconData 
                  ? Icon(icon, color: isActive ? color : Colors.black.withOpacity(0.2), size: 24)
                  : FaIcon(icon, color: isActive ? color : Colors.black.withOpacity(0.2), size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isActive ? const Color(0xFF0F172A) : Colors.black.withOpacity(0.2))),
        ],
      ),
    );
  }

  Widget _buildSocialSection(Lead currentLead) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSocialIcon(FontAwesomeIcons.instagram, const Color(0xFFE1306C), currentLead.instagram),
          _buildSocialIcon(FontAwesomeIcons.facebook, const Color(0xFF1877F2), currentLead.facebook),
          _buildSocialIcon(FontAwesomeIcons.linkedin, const Color(0xFF0A66C2), currentLead.linkedin),
          _buildSocialIcon(FontAwesomeIcons.twitter, const Color(0xFF1DA1F2), currentLead.twitter),
          _buildSocialIcon(FontAwesomeIcons.youtube, const Color(0xFFFF0000), currentLead.youtube),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(dynamic icon, Color color, String? link) {
    bool isAvailable = link != null && link.isNotEmpty && link != 'N/A';
    return InkWell(
      onTap: isAvailable ? () => _launchURL(link) : null,
      child: Opacity(
        opacity: isAvailable ? 1.0 : 0.1,
        child: icon is IconData
            ? Icon(icon, color: color, size: 24)
            : FaIcon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildAddressSection(Lead currentLead) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentLead.address ?? 'No physical address listed.', 
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155), height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            currentLead.city ?? '', 
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  void _launchWhatsApp(Lead lead) async {
    final user = GetStorage().read('user') ?? {};
    final myOrg = user['organization_name'] ?? 'my company';
    final myName = user['name'] ?? 'me';
    
    String message = "Hi ${lead.businessName},\n\n"
        "${lead.aiPitch ?? "I noticed your business in ${lead.city ?? 'your area'} and would love to chat."}\n\n- $myName from $myOrg";
    
    final encodedMsg = Uri.encodeComponent(message);
    final normalizedPhone = lead.phone!.replaceAll(RegExp(r'\D'), '');
    final url = "https://wa.me/$normalizedPhone?text=$encodedMsg";
    _launchURL(url);
  }

  void _launchURL(String url) async {
    if (url.isEmpty || url == 'N/A') return;
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showStatusUpdateDialog(BuildContext context, LeadController controller) {
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

  void _confirmDelete(BuildContext context, LeadController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(30),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.delete_forever_rounded, color: Color(0xFFEF4444), size: 32),
            ),
            const SizedBox(height: 20),
            const Text('Delete Lead?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            const SizedBox(height: 10),
            Text(
              'Are you sure? This lead and all its data will be permanently removed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.4), height: 1.5, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel', style: TextStyle(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.deleteLead(lead.id!);
                      Get.back();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'New': return const Color(0xFF3B82F6);
      case 'Contacted': return const Color(0xFF8B5CF6);
      case 'Interested': return const Color(0xFFF59E0B);
      case 'Converted': return const Color(0xFF10B981);
      case 'Not Interested': return const Color(0xFFEF4444);
      default: return const Color(0xFF64748B);
    }
  }
}
