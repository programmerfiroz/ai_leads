import 'package:flutter_contacts/flutter_contacts.dart';
import '../models/lead_model.dart';

class ContactService {
  Future<bool> requestPermission() async {
    final status = await FlutterContacts.permissions.request(PermissionType.readWrite);
    return status == PermissionStatus.granted;
  }

  Future<Set<String>> getSavedPhoneNumbers() async {
    if (!await requestPermission()) return {};
    
    // Fetch contacts with phone numbers specifically for normalization
    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );
    
    final Set<String> numbers = {};
    for (var contact in contacts) {
      for (var phone in contact.phones) {
        final normalized = phone.number.replaceAll(RegExp(r'\D'), '');
        if (normalized.isNotEmpty) {
          numbers.add(normalized);
        }
      }
    }
    return numbers;
  }

  Future<bool> checkIfContactExists(String phoneNumber) async {
    final savedNumbers = await getSavedPhoneNumbers();
    final normalized = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return savedNumbers.contains(normalized);
  }

  Future<bool> saveToContacts(Lead lead) async {
    if (!await requestPermission()) return false;

    if (lead.phone == null || lead.phone!.isEmpty) return false;

    // Check if exists first to prevent duplicates
    if (await checkIfContactExists(lead.phone!)) return true;

    final emails = <Email>[];
    if (lead.email != null && lead.email!.isNotEmpty) {
      emails.add(Email(address: lead.email!));
    }

    final websites = <Website>[];
    if (lead.website != null && lead.website!.isNotEmpty) {
      websites.add(Website(url: lead.website!));
    }

    String namePart = lead.businessName;
    if (lead.category != null && lead.category!.isNotEmpty) {
      namePart += " - ${lead.category}";
    }
    if (lead.city != null && lead.city!.isNotEmpty) {
      namePart += " - ${lead.city}";
    }
    final contactName = "Lead - $namePart";
    
    final newContact = Contact(
      name: Name(first: contactName),
      phones: [Phone(number: lead.phone!)],
      emails: emails,
      websites: websites,
    );

    try {
      await FlutterContacts.create(newContact);
      return true;
    } catch (e) {
      print('Error saving contact: $e');
      return false;
    }
  }

  Future<int> bulkSave(List<Lead> leads) async {
    if (!await requestPermission()) return 0;

    int savedCount = 0;
    for (var lead in leads) {
      final success = await saveToContacts(lead);
      if (success) savedCount++;
    }
    return savedCount;
  }
}
