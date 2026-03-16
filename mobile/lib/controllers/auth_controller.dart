import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';
import '../views/screens/signup_screen.dart';
import 'lead_controller.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final _storage = GetStorage();

  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    final token = _storage.read('token');
    isLoggedIn.value = token != null;
  }

  Future<void> login(String phone, String otp) async {
    try {
      isLoading.value = true;
      final data = await _apiService.login(phone, otp);
      
      // Check if user has completed profile
      final user = data['user'];
      if (user['organization_name'] == null || user['business_category'] == null) {
        throw Exception('User not found. Please register.');
      }

      isLoggedIn.value = true;
      Get.find<LeadController>().refreshLeads();
      Get.offAllNamed('/dashboard');
    } catch (e) {
      final errorStr = e.toString();
      if (errorStr.contains('User not found') || errorStr.contains('404')) {
        Get.snackbar('Profile Required', 'No profile found for this number. Please register.', 
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF6C63FF).withOpacity(0.8),
            colorText: Colors.white);
        Get.to(() => const SignupScreen(), arguments: {'phone': phone});
      } else {
        Get.snackbar('Login Failed', errorStr, snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;
      await _apiService.register(userData);
      isLoggedIn.value = true;
      Get.find<LeadController>().refreshLeads();
      Get.offAllNamed('/dashboard');
    } catch (e) {
      Get.snackbar('Registration Failed', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _storage.remove('token');
    _storage.remove('user');
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
