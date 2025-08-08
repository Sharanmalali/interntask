import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import Firebase Auth

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key}); // ✅ Use const constructor

  @override
  _DriverRegistrationPageState createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final regNumberController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final licenseExpiryController = TextEditingController();

  String selectedCarType = 'Sedan';
  final List<String> carTypes = ['Sedan', 'SUV', 'Hatchback', 'Mini Van'];

  // ✅ New state variables
  bool _isLoading = false;
  
  // ✅ Pre-fill email from Firebase user
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      emailController.text = user.email!;
    }
  }


  Future<void> registerDriver() async {
    // ✅ Get the currently logged-in user from Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error: You must be logged in to register.")),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do not proceed
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    final url = Uri.parse('http://10.187.64.208:3000/api/drivers/register');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': nameController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'email': emailController.text,
          'carRegNumber': regNumberController.text,
          'carType': selectedCarType,
          'licenseNumber': licenseNumberController.text,
          'licenseExpiry': licenseExpiryController.text,
          'firebase_uid': user.uid, // ✅ Send the Firebase UID
        }),
      );

      if (mounted) { // Check if the widget is still in the tree
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Driver registered successfully")),
          );
          Navigator.pop(context); // Go back to home page on success
        } else {
          // Decode the error message from the server
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
          _isLoading = false; // Stop loading
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
      backgroundColor: const Color(0xFF1C1C1C), // Dark grey background
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text("Driver Registration", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
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
                controller: emailController,
                decoration: _buildInputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                readOnly: true, // Make email read-only as it's from Firebase
                validator: (value) => value!.isEmpty ? 'Email cannot be empty' : null,
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
                onPressed: _isLoading ? null : registerDriver, // Disable button when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Register',
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