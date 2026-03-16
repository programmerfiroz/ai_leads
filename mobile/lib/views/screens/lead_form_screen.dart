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
      appBar: AppBar(
        title: Text(widget.lead == null ? 'Add Manual Lead' : 'Edit Lead'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField(_nameController, 'Business Name', Icons.business, isRequired: true),
              const SizedBox(height: 15),
              _buildField(_phoneController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 15),
              _buildField(_cityController, 'City', Icons.location_city),
              const SizedBox(height: 15),
              _buildField(_categoryController, 'Category', Icons.category),
              const SizedBox(height: 15),
              _buildField(_websiteController, 'Website', Icons.language, keyboardType: TextInputType.url),
              const SizedBox(height: 15),
              _buildField(_addressController, 'Address', Icons.map, maxLines: 3),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildField(_ratingController, 'Rating', Icons.star, keyboardType: TextInputType.number)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildField(_reviewsController, 'Reviews', Icons.chat_bubble)),
                ],
              ),
              const SizedBox(height: 15),
              _buildField(_hoursController, 'Opening Hours', Icons.access_time),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  prefixIcon: const Icon(Icons.info_outline),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
                items: ['New', 'Contacted', 'Interested', 'Converted', 'Not Interested']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _saveForm,
                  child: Obx(() => _controller.isLoading.value 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.lead == null ? 'Save Lead' : 'Update Lead', 
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                ),
              ),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (val) => isRequired && (val == null || val.isEmpty) ? 'Required' : null,
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
