import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/lead_controller.dart';
import '../../models/lead_model.dart';

class LeadFormScreen extends StatefulWidget {
  final Lead? lead;
  const LeadFormScreen({super.key, this.lead});

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final LeadController _controller = Get.find<LeadController>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _categoryController;
  late TextEditingController _websiteController;
  late TextEditingController _addressController;
  late TextEditingController _ratingController;
  late TextEditingController _reviewsController;
  late TextEditingController _hoursController;
  String _status = 'New';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lead?.businessName);
    _phoneController = TextEditingController(text: widget.lead?.phone);
    _cityController = TextEditingController(text: widget.lead?.city);
    _categoryController = TextEditingController(text: widget.lead?.category);
    _websiteController = TextEditingController(text: widget.lead?.website);
    _addressController = TextEditingController(text: widget.lead?.address);
    _ratingController = TextEditingController(text: widget.lead?.rating);
    _reviewsController = TextEditingController(text: widget.lead?.reviewsCount);
    _hoursController = TextEditingController(text: widget.lead?.openingHours);
    _status = widget.lead?.status ?? 'New';
  }

  @override
  Widget build(BuildContext context) {
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
          widget.lead == null ? 'Add Manual Lead' : 'Edit Lead Details',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Business Information',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.8),
              ),
              const SizedBox(height: 20),
              _buildField(_nameController, 'Business Name', Icons.business_rounded, isRequired: true),
              const SizedBox(height: 16),
              _buildField(_phoneController, 'Phone Number', Icons.phone_rounded, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildField(_cityController, 'City', Icons.location_on_rounded),
              const SizedBox(height: 16),
              _buildField(_categoryController, 'Category', Icons.category_rounded),
              const SizedBox(height: 24),
              const Text(
                'Online Presence',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.8),
              ),
              const SizedBox(height: 20),
              _buildField(_websiteController, 'Website URL', Icons.language_rounded, keyboardType: TextInputType.url),
              const SizedBox(height: 16),
              _buildField(_addressController, 'Physical Address', Icons.map_rounded, maxLines: 2),
              const SizedBox(height: 24),
              const Text(
                'Engagement Info',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.8),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildField(_ratingController, 'Rating', Icons.star_rounded, keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField(_reviewsController, 'Reviews', Icons.comment_rounded)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField(_hoursController, 'Business Hours', Icons.access_time_rounded),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: Colors.white,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                decoration: InputDecoration(
                  labelText: 'Engagement Status',
                  labelStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w600),
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.04),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black.withOpacity(0.04))),
                  prefixIcon: const Icon(Icons.info_outline_rounded, size: 20),
                ),
                items: ['New', 'Contacted', 'Interested', 'Converted', 'Not Interested']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF056E73),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _saveForm,
                  child: Obx(() => _controller.isLoading.value 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.lead == null ? 'Save Lead' : 'Update Lead', 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, 
      {bool isRequired = false, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.3), fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.black.withOpacity(0.04))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF056E73), width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      validator: (val) => isRequired && (val == null || val.isEmpty) ? 'This field is required' : null,
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'business_name': _nameController.text,
        'phone': _phoneController.text,
        'city': _cityController.text,
        'category': _categoryController.text,
        'website': _websiteController.text,
        'address': _addressController.text,
        'status': _status,
        'rating': _ratingController.text,
        'reviews_count': _reviewsController.text,
        'opening_hours': _hoursController.text,
      };

      if (widget.lead == null) {
        _controller.addLead(data);
      } else {
        _controller.updateLeadDetails(widget.lead!.id!, data);
      }
    }
  }
}
