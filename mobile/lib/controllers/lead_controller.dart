import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/lead_model.dart';
import '../services/api_service.dart';
import '../services/contact_service.dart';
import 'package:flutter/material.dart';

class LeadController extends GetxController {
  final ApiService _apiService = ApiService();
  final ContactService _contactService = ContactService();
  
  var leads = <Lead>[].obs;
  var isLoading = true.obs;
  var stats = {
    'total': 0,
    'new': 0,
    'contacted': 0,
    'converted': 0,
  }.obs;

  @override
  void onInit() {
    super.onInit();
    final token = GetStorage().read('token');
    if (token != null) {
      fetchLeads();
      fetchStats();
    }
  }

  void fetchLeads({String? city, String? category, String? status, String? search}) async {
    try {
      final token = GetStorage().read('token');
      if (token == null) {
        isLoading(false);
        return;
      }
      isLoading(true);
      var fetchedLeads = await _apiService.getLeads(
        city: city,
        category: category,
        status: status,
        search: search,
      );
      leads.value = fetchedLeads;
      await syncLocalContacts();
    } catch (e) {
      print('Error fetching leads: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> syncLocalContacts() async {
    final savedNumbers = await _contactService.getSavedPhoneNumbers();
    final viewedIds = Set<int>.from(GetStorage().read<List>('viewed_leads') ?? []);
    
    for (var lead in leads) {
      if (lead.phone != null) {
        final normalizedLeadPhone = lead.phone!.replaceAll(RegExp(r'\D'), '');
        lead.isSavedLocally = savedNumbers.contains(normalizedLeadPhone);
      }
      if (lead.id != null) {
        lead.isViewed = viewedIds.contains(lead.id);
      }
    }
    leads.refresh(); // Trigger UI update for the whole list
  }

  void markAsViewed(Lead lead) {
    if (lead.id == null || lead.isViewed) return;
    
    final storage = GetStorage();
    final List viewedList = storage.read('viewed_leads') ?? [];
    if (!viewedList.contains(lead.id)) {
      viewedList.add(lead.id);
      storage.write('viewed_leads', viewedList);
      lead.isViewed = true;
      leads.refresh();
    }
  }

  Future<void> saveLeadToContacts(Lead lead) async {
    final success = await _contactService.saveToContacts(lead);
    if (success) {
      lead.isSavedLocally = true;
      leads.refresh();
      Get.snackbar('Success', '${lead.businessName} saved to contacts');
    } else {
      Get.snackbar('Error', 'Failed to save contact');
    }
  }

  Future<void> bulkSaveToContacts() async {
    final unsavedLeads = leads.where((l) => !l.isSavedLocally).toList();
    if (unsavedLeads.isEmpty) {
      Get.snackbar('Info', 'All leads already saved');
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    int count = await _contactService.bulkSave(unsavedLeads);
    Get.back(); // Close dialog

    if (count > 0) {
      await syncLocalContacts();
      Get.snackbar('Success', '$count new contacts saved');
    } else {
      Get.snackbar('Info', 'No new contacts saved');
    }
  }

  void fetchStats() async {
    try {
      final token = GetStorage().read('token');
      if (token == null) return;
      
      var fetchedStats = await _apiService.getStats();
      stats.value = Map<String, int>.from(fetchedStats);
    } catch (e) {
      print('Error fetching stats: $e');
    }
  }

  Future<void> refreshLeads() async {
    fetchLeads();
    fetchStats();
  }

  Future<void> updateLeadStatus(int id, String status, {String? notes}) async {
    var success = await _apiService.updateStatus(id, status, notes: notes);
    if (success) {
      refreshLeads();
      Get.snackbar('Success', 'Status updated successfully');
    } else {
      Get.snackbar('Error', 'Failed to update status');
    }
  }

  Future<void> addLead(Map<String, dynamic> data) async {
    try {
      isLoading(true);
      await _apiService.createLead(data);
      refreshLeads();
      Get.back();
      Get.snackbar('Success', 'Lead added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add lead: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateLeadDetails(int id, Map<String, dynamic> data) async {
    try {
      isLoading(true);
      await _apiService.updateLead(id, data);
      refreshLeads();
      Get.back();
      Get.snackbar('Success', 'Lead updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update lead: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteLead(int id) async {
    try {
      var success = await _apiService.deleteLead(id);
      if (success) {
        refreshLeads();
        Get.back();
        Get.snackbar('Success', 'Lead deleted successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete lead: $e');
    }
  }

  Future<void> scrapeLeads(String keyword, String location) async {
    try {
      isLoading(true);
      bool success = await _apiService.scrapeLeads(keyword, location);
      if (success) {
        Get.snackbar(
          'Success', 
          'Scraping process initiated for $keyword in $location. Leads will appear shortly.',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar('Error', 'Failed to initiate scraping');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }
}
