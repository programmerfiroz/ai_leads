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
      appBar: AppBar(
        title: Text(lead.businessName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Get.to(() => LeadFormScreen(lead: lead)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.edit_note),
            onPressed: () => _showStatusUpdateDialog(context, controller),
          )
        ],
      ),
      body: Obx(() {
        // Find the most recent version of this lead in the controller
        final currentLead = controller.leads.firstWhere((l) => l.id == lead.id, orElse: () => lead);
        
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(currentLead),
              _buildPerformanceStats(currentLead),
              _buildContactSection(currentLead),
              _buildActionButtons(controller, currentLead),
              _buildPitchSuggestions(currentLead),
              _buildSocialSection(currentLead),
              _buildAddressSection(currentLead),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPitchSuggestions(Lead currentLead) {
    final hasAiPitch = currentLead.aiPitch != null && currentLead.aiPitch!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 10),
              const Text('AI Business Analysis & Pitch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
            ],
          ),
          const SizedBox(height: 15),
          if (hasAiPitch)
            Text(
              currentLead.aiPitch!,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.white, fontStyle: FontStyle.italic),
              softWrap: true,
            )
          else ...[
            _buildPitchItem('Personalize', 'Mention their business name and "${currentLead.city ?? 'local'}" location.'),
            _buildPitchItem('Reviews', 'If reviews are low, offer GMB profile optimization.'),
            _buildPitchItem('Website', 'If no website, offer a fast mobile-friendly site.'),
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
          const Padding(
            padding: EdgeInsets.only(top: 5.0),
            child: Icon(Icons.check_circle_outline, size: 14, color: Colors.amber),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(description, style: const TextStyle(fontSize: 13, color: Colors.white70)),
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
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Get.theme.cardColor,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const CircleAvatar(radius: 40, backgroundColor: Colors.white12, child: Icon(Icons.business, size: 40)),
          const SizedBox(height: 15),
          Text(
            currentLead.businessName, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(currentLead.category ?? 'Business Category', style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 15),
          if (currentLead.status != 'New' || !currentLead.isViewed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
              child: Text(currentLead.status, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats(Lead currentLead) {
    if ((currentLead.rating == null || currentLead.rating!.isEmpty) && 
        (currentLead.reviewsCount == null || currentLead.reviewsCount!.isEmpty) &&
        (currentLead.openingHours == null || currentLead.openingHours!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.star_rounded, currentLead.rating ?? 'N/A', 'Rating', Colors.orange),
          _buildStatDivider(),
          _buildStatItem(Icons.chat_bubble_outline_rounded, currentLead.reviewsCount ?? '0', 'Reviews', Colors.blue),
          _buildStatDivider(),
          _buildStatItem(Icons.access_time_rounded, currentLead.openingHours ?? 'N/A', 'Hours', Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 30, width: 1, color: Colors.white10);
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildContactSection(Lead currentLead) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoTile(Icons.person_outline, 'Owner', currentLead.ownerName ?? 'Not Available'),
          _buildInfoTile(Icons.phone_outlined, 'Phone', currentLead.phone ?? 'Not Available'),
          _buildInfoTile(Icons.email_outlined, 'Email', currentLead.email ?? 'Not Available'),
          _buildInfoTile(Icons.language_outlined, 'Website', currentLead.website ?? 'Not Available'),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Get.theme.primaryColor, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            Icons.phone, 
            'Call', 
            hasPhone ? Colors.blue : Colors.white10, 
            hasPhone ? () {
              final phone = currentLead.phone!.replaceAll(RegExp(r'\D'), '');
              _launchURL('tel:$phone');
            } : () {}
          ),
          _buildActionButton(
            FontAwesomeIcons.whatsapp, 
            'WhatsApp', 
            hasPhone ? Colors.green : Colors.white10, 
            hasPhone ? () => _launchWhatsApp(currentLead) : () {}
          ),
          _buildActionButton(
            currentLead.isSavedLocally ? Icons.person_search : Icons.person_add_outlined, 
            currentLead.isSavedLocally ? 'Added' : 'Save', 
            hasPhone ? (currentLead.isSavedLocally ? Colors.grey : Colors.blueAccent) : Colors.white10, 
            hasPhone ? (currentLead.isSavedLocally ? () {} : () => controller.saveLeadToContacts(currentLead)) : () {}
          ),
          _buildActionButton(Icons.map_outlined, 'Maps', Colors.orange, () => _launchURL(currentLead.mapsLink ?? '')),
        ],
      ),
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

  Widget _buildActionButton(dynamic icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: icon is IconData 
                ? Icon(icon, color: color, size: 20)
                : FaIcon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSocialSection(Lead currentLead) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Social Media', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildSocialIcon(FontAwesomeIcons.instagram, Colors.pink, currentLead.instagram),
              const SizedBox(width: 20),
              _buildSocialIcon(FontAwesomeIcons.facebook, Colors.blueAccent, currentLead.facebook),
              const SizedBox(width: 20),
              _buildSocialIcon(FontAwesomeIcons.linkedin, Colors.blue.shade700, currentLead.linkedin),
              const SizedBox(width: 20),
              _buildSocialIcon(FontAwesomeIcons.twitter, Colors.lightBlue, currentLead.twitter),
              const SizedBox(width: 20),
              _buildSocialIcon(FontAwesomeIcons.youtube, Colors.red, currentLead.youtube),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(dynamic icon, Color color, String? link) {
    bool isAvailable = link != null && link.isNotEmpty && link != 'N/A';
    return GestureDetector(
      onTap: isAvailable ? () => _launchURL(link) : null,
      child: icon is IconData
          ? Icon(icon, color: isAvailable ? color : Colors.white10, size: 30)
          : FaIcon(icon, color: isAvailable ? color : Colors.white10, size: 30),
    );
  }

  Widget _buildAddressSection(Lead currentLead) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(currentLead.address ?? 'No address provided', style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text(currentLead.city ?? '', style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    if (url.isEmpty || url == 'N/A') return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showStatusUpdateDialog(BuildContext context, LeadController controller) {
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

  void _confirmDelete(BuildContext context, LeadController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Lead?'),
        content: const Text('Are you sure you want to delete this lead? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => controller.deleteLead(lead.id!),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
