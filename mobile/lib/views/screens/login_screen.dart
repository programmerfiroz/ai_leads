import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.put(AuthController());
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool otpStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.auto_graph, size: 80, color: Color(0xFF6C63FF)),
              const SizedBox(height: 20),
              Text(
                'AI Lead CRM',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                otpStatus ? 'Verify your phone number' : 'Login to your account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 50),
              if (!otpStatus)
                _buildTextField(_phoneController, 'Phone Number', Icons.phone_outlined, keyboardType: TextInputType.phone)
              else
                _buildTextField(_otpController, '4-Digit OTP', Icons.lock_outline, keyboardType: TextInputType.number),
              
              const SizedBox(height: 40),
              Obx(() => ElevatedButton(
                onPressed: authController.isLoading.value ? null : () => _handleAction(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: authController.isLoading.value 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(otpStatus ? 'Verify & Login' : 'Send OTP', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              )),
              
              const SizedBox(height: 20),
              if (otpStatus)
                TextButton(
                  onPressed: () => setState(() => otpStatus = false),
                  child: const Text('Change Phone Number', style: TextStyle(color: Colors.white60)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  void _handleAction() {
    if (!otpStatus) {
      if (_phoneController.text.length < 10) {
        Get.snackbar('Error', 'Enter a valid phone number', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      setState(() => otpStatus = true);
      Get.snackbar('Success', 'OTP Sent (Use 1234)', snackPosition: SnackPosition.BOTTOM);
    } else {
      if (_otpController.text != '1234') {
        Get.snackbar('Error', 'Invalid OTP. Use 1234', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      authController.login(_phoneController.text, _otpController.text);
    }
  }
}
