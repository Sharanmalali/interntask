import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class EditDriverProfilePage extends StatefulWidget {
  final Map<String, dynamic> driverData;

  const EditDriverProfilePage({super.key, required this.driverData});

  @override
  _EditDriverProfilePageState createState() => _EditDriverProfilePageState();
}

class _EditDriverProfilePageState extends State<EditDriverProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController regNumberController;
  late TextEditingController licenseNumberController;
  late TextEditingController licenseExpiryController;

  String? selectedCarType;
  final List<String> carTypes = ['Sedan', 'SUV', 'Hatchback', 'Mini Van'];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    nameController = TextEditingController(text: widget.driverData['name']);
    phoneController = TextEditingController(text: widget.driverData['phone']);
    addressController = TextEditingController(text: widget.driverData['address']);
    regNumberController = TextEditingController(text: widget.driverData['car_reg_number']);
    licenseNumberController = TextEditingController(text: widget.driverData['license_number']);
    licenseExpiryController = TextEditingController(text: widget.driverData['license_expiry']);
    selectedCarType = widget.driverData['car_type'];
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do not proceed
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: You are not logged in.")),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final idToken = await user.getIdToken(true);
      final url = Uri.parse('http://10.187.64.208:3000/api/drivers/profile');
      
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'car_reg_number': regNumberController.text,
          'car_type': selectedCarType,
          'license_number': licenseNumberController.text,
          'license_expiry': licenseExpiryController.text,
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Profile updated successfully!")),
          );
          // Pop with 'true' to indicate success
          Navigator.pop(context, true);
        } else {
          final errorBody = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Error: ${errorBody['error']}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ An error occurred: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.grey[850],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: _buildInputDecoration('Name'),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: _buildInputDecoration('Phone Number'),
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                decoration: _buildInputDecoration('Home Address'),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: regNumberController,
                decoration: _buildInputDecoration('Car Registration Number'),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Please enter your car registration' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCarType,
                decoration: _buildInputDecoration('Car Type'),
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                items: carTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCarType = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: licenseNumberController,
                decoration: _buildInputDecoration('License Number'),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Please enter your license number' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: licenseExpiryController,
                decoration: _buildInputDecoration('License Expiry Date (YYYY-MM-DD)'),
                style: const TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? 'Please enter license expiry date' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
