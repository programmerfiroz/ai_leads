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
        width: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            // Mesh Background Accents
            Positioned(
              top: -80,
              left: -80,
              child: _buildGradientCircle(350, const Color(0xFF056E73).withOpacity(0.06)),
            ),
            Positioned(
              bottom: 200,
              left: -100,
              child: _buildGradientCircle(380, const Color(0xFF6366F1).withOpacity(0.04)),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _buildGradientCircle(300, const Color(0xFFB2D430).withOpacity(0.08)),
            ),
            
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withOpacity(0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                          BoxShadow(
                            color: const Color(0xFF056E73).withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: 65,
                          height: 65,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  const SizedBox(height: 35),
                  Text(
                    otpStatus ? 'Verification' : 'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    otpStatus ? 'Enter the security code' : 'Sign in to manage your business leads',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Premium Input Group
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: otpStatus
                        ? _buildPremiumTextField(_otpController, '4-Digit OTP', Icons.lock_open_rounded, keyboardType: TextInputType.number)
                        : _buildPremiumTextField(_phoneController, 'Phone Number', Icons.phone_android_rounded, keyboardType: TextInputType.phone),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // High-end Button
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF056E73).withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: authController.isLoading.value ? null : () => _handleAction(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF056E73),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: authController.isLoading.value 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            otpStatus ? 'VERIFY & CONTINUE' : 'SEND OTP', 
                            style: TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.w700, 
                              letterSpacing: 1.2,
                            ),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  if (otpStatus)
                    TextButton(
                      onPressed: () => setState(() => otpStatus = false),
                      child: Text(
                        'Change phone number?', 
                        style: TextStyle(
                          color: Colors.black26,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }

  Widget _buildPremiumTextField(TextEditingController controller, String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.black26, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFF056E73).withOpacity(0.4), size: 18),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.04),
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
