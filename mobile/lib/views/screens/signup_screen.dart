import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthController authController = Get.find<AuthController>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _orgController = TextEditingController();
  final _categoryController = TextEditingController();
  
  final List<String> _categories = [
    'Real Estate', 'Education', 'IT & Software', 'Healthcare', 
    'E-commerce', 'Marketing Agency', 'Manufacturing', 'Finance',
    'Hospitality', 'Automobile', 'Fitness', 'Legal', 'Media', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args['phone'] != null) {
      _phoneController.text = args['phone'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _orgController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    String search = '';
    Get.bottomSheet(
      StatefulBuilder(builder: (context, setModalState) {
        final filtered = _categories.where((c) => c.toLowerCase().contains(search.toLowerCase())).toList();
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Category...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setModalState(() => search = val),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => ListTile(
                    title: Text(filtered[i]),
                    onTap: () {
                      _categoryController.text = filtered[i];
                      Get.back();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            // Mesh Background Accents
            Positioned(
              top: -60,
              right: -60,
              child: _buildGradientCircle(300, const Color(0xFF056E73).withOpacity(0.06)),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: _buildGradientCircle(250, const Color(0xFFB2D430).withOpacity(0.08)),
            ),
            
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Text(
                    'Profile Setup',
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
                    'Let\'s build your business profile' ,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 50),
                  
                  // Premium Input Group
                  _buildPremiumGroup([
                    _buildPremiumTextField(_nameController, 'Full Name', Icons.person_rounded),
                    const Divider(height: 1, color: Colors.black12, indent: 20, endIndent: 20),
                    _buildPremiumTextField(_emailController, 'Email Address', Icons.email_rounded),
                    const Divider(height: 1, color: Colors.black12, indent: 20, endIndent: 20),
                    _buildPremiumTextField(_orgController, 'Organization', Icons.business_center_rounded),
                    const Divider(height: 1, color: Colors.black12, indent: 20, endIndent: 20),
                    GestureDetector(
                      onTap: _showCategoryPicker,
                      child: AbsorbPointer(
                        child: _buildPremiumTextField(_categoryController, 'Business Category', Icons.category_rounded),
                      ),
                    ),
                  ]),
                  
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
                      onPressed: authController.isLoading.value ? null : () => _handleSignup(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF056E73),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: authController.isLoading.value 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            'CONFIRM PROFILE', 
                            style: TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.w700, 
                              letterSpacing: 1.2,
                            ),
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

  Widget _buildPremiumGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildPremiumTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.black26, fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: const Color(0xFF056E73).withOpacity(0.4), size: 18),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.03),
      ),
    );
  }

  void _handleSignup() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _phoneController.text.isEmpty || _orgController.text.isEmpty || _categoryController.text.isEmpty) {
      Get.snackbar('Error', 'All fields are required', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    authController.register({
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'organization_name': _orgController.text,
      'business_category': _categoryController.text,
    });
  }
}
