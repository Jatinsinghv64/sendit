import 'package:flutter/material.dart';
import '../DatabaseService.dart';
import '../models/product.dart';
import '../themes.dart';

class AddEditAddressScreen extends StatefulWidget {
  final UserAddress? address; // If null, it's Add mode

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;

  String _selectedLabel = 'Home'; // Home, Work, Other
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final addr = widget.address;
    _nameController = TextEditingController(text: addr?.fullName ?? '');
    _phoneController = TextEditingController(text: addr?.phone ?? '');
    _streetController = TextEditingController(text: addr?.street ?? '');
    _cityController = TextEditingController(text: addr?.city ?? '');
    _stateController = TextEditingController(text: addr?.state ?? '');
    _zipController = TextEditingController(text: addr?.zipCode ?? '');
    _selectedLabel = addr?.label ?? 'Home';
    _isDefault = addr?.isDefault ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.address == null ? "Add Address" : "Edit Address"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("CONTACT DETAILS"),
              _buildTextField("Full Name", _nameController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField("Phone Number", _phoneController, Icons.phone_outlined, isNumber: true),

              const SizedBox(height: 24),
              _buildSectionTitle("ADDRESS INFO"),
              _buildTextField("Street / Flat / Building", _streetController, Icons.home_outlined, maxLines: 2),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField("City", _cityController, Icons.location_city)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("Pincode", _zipController, Icons.pin_drop_outlined, isNumber: true)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField("State", _stateController, Icons.map_outlined),

              const SizedBox(height: 24),
              _buildSectionTitle("SAVE AS"),
              Row(
                children: ["Home", "Work", "Other"].map((label) {
                  final isSelected = _selectedLabel == label;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedLabel = label),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Make this my default address", style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isDefault,
                activeColor: AppTheme.primaryColor,
                onChanged: (val) => setState(() => _isDefault = val),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  child: _isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("SAVE ADDRESS"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        alignLabelWithHint: true,
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final newAddress = UserAddress(
        id: widget.address?.id ?? '', // ID handled by DB for new
        label: _selectedLabel,
        fullName: _nameController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zipCode: _zipController.text.trim(),
        phone: _phoneController.text.trim(),
        isDefault: _isDefault,
      );

      if (widget.address == null) {
        await DatabaseService().addAddress(newAddress);
      } else {
        await DatabaseService().updateAddress(newAddress);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}