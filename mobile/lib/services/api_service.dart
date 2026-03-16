import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead_model.dart';

import 'package:get_storage/get_storage.dart';

class ApiService {
  static const String baseUrl = 'https://ai-leads.brainket.online/api';
  final _storage = GetStorage();

  String? get token => _storage.read('token');

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String phone, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: jsonEncode({'phone': phone, 'otp': otp}),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write('token', data['access_token']);
      await _storage.write('user', data['user']);
      return data;
    } else {
      print('Login Error: ${response.statusCode} - ${response.body}');
      String errorMessage = 'Failed to login';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? 'Failed to login';
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: jsonEncode(userData),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write('token', data['access_token']);
      await _storage.write('user', data['user']);
      return data;
    } else {
      print('Registration Error: ${response.statusCode} - ${response.body}');
      String errorMessage = 'Failed to register';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? 'Failed to register';
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  Future<List<Lead>> getLeads({String? city, String? category, String? status, String? search}) async {
    final queryParams = <String, String>{};
    if (city != null) queryParams['city'] = city;
    if (category != null) queryParams['category'] = category;
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse('$baseUrl/leads').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: _headers());

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Lead.fromJson(data)).toList();
    } else {
      print('API Error (getLeads): ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load leads: ${response.statusCode}');
    }
  }

  Future<Lead> getLead(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/lead/$id'), headers: _headers());
    if (response.statusCode == 200) {
      return Lead.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load lead details');
    }
  }

  Future<bool> updateStatus(int id, String status, {String? notes}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/lead/update-status'),
      body: jsonEncode({
        'id': id,
        'status': status,
        'notes': notes,
      }),
      headers: _headers(),
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await http.get(Uri.parse('$baseUrl/dashboard-stats'), headers: _headers());
    if (response.statusCode == 200) {
      return Map<String, int>.from(json.decode(response.body));
    } else {
      print('API Error (getStats): ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }

  Future<bool> deleteLead(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/lead/$id'), headers: _headers());
    return response.statusCode == 200;
  }

  Future<Lead> createLead(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/leads'),
      body: jsonEncode(data),
      headers: _headers(),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Lead.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create lead');
    }
  }

  Future<Lead> updateLead(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/lead/$id'),
      body: jsonEncode(data),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      return Lead.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update lead');
    }
  }

  Future<bool> scrapeLeads(String keyword, String location) async {
    final response = await http.post(
      Uri.parse('$baseUrl/scrape-leads'),
      body: jsonEncode({
        'keyword': keyword,
        'location': location,
      }),
      headers: _headers(),
    );
    return response.statusCode == 200;
  }
}
