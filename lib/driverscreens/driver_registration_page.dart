import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverRegistrationPage extends StatefulWidget {
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

  Future<void> registerDriver() async {
    final url = Uri.parse('http://10.187.64.208:3000/api/drivers/register');
 // adjust for production
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
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Driver registered successfully")),
      );
      _formKey.currentState!.reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: ${response.body}")),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1C), // Dark grey background
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text("Driver Registration", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
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
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: _buildInputDecoration('Phone Number'),
                keyboardType: TextInputType.phone,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: addressController,
                decoration: _buildInputDecoration('Home Address'),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: _buildInputDecoration('Email'),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: regNumberController,
                decoration: _buildInputDecoration('Car Registration Number'),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCarType,
                decoration: _buildInputDecoration('Car Type'),
                dropdownColor: Colors.grey[900],
                style: TextStyle(color: Colors.white),
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
              SizedBox(height: 10),
              TextFormField(
                controller: licenseNumberController,
                decoration: _buildInputDecoration('License Number'),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: licenseExpiryController,
                decoration: _buildInputDecoration('License Expiry Date (YYYY-MM-DD)'),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) registerDriver();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
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

