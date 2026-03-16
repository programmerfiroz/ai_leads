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
            color: Color(0xFF1E293B),
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
                  fillColor: Colors.white10,
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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Complete Your Profile',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Fill in your business details',
              style: TextStyle(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            _buildTextField(_nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(_emailController, 'Email Address', Icons.email_outlined),
            const SizedBox(height: 20),
            _buildTextField(_orgController, 'Organization Name', Icons.business_outlined),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _showCategoryPicker,
              child: AbsorbPointer(
                child: _buildTextField(_categoryController, 'Business Category', Icons.category_outlined),
              ),
            ),
            const SizedBox(height: 40),
            Obx(() => ElevatedButton(
              onPressed: authController.isLoading.value ? null : () => _handleSignup(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: authController.isLoading.value 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Confirm Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
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
