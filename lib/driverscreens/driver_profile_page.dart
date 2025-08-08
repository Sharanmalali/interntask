import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _driverData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDriverProfile();
  }

  Future<void> _fetchDriverProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _error = "You are not logged in.";
        _isLoading = false;
      });
      return;
    }

    try {
      // Force refresh the token to ensure it's not expired
      final idToken = await user.getIdToken(true);
      final url = Uri.parse('http://10.187.64.208:3000/api/drivers/profile');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken', // Send the token for verification
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _driverData = json.decode(response.body);
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _error = "Profile not found. Please complete your driver registration.";
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load profile. Server returned status ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      // Clear all routes and push to the root (AuthHome)
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }
  
  void _editProfile() {
      // We will implement this in the next step
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Edit functionality coming soon!")),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Driver Profile'),
        backgroundColor: Colors.grey[850],
        actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
                tooltip: 'Logout',
            )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_driverData == null) {
      return const Center(
        child: Text(
          "No profile data available.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // A header card for the name
          Card(
            color: Colors.grey[800],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Icon(Icons.person_pin, color: Colors.amber, size: 50),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _driverData!['name'] ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _driverData!['email'] ?? 'N/A',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Details section
          _buildDetailTile(Icons.phone, 'Phone Number', _driverData!['phone']),
          _buildDetailTile(Icons.home, 'Address', _driverData!['address']),
          _buildDetailTile(Icons.directions_car, 'Car Type', _driverData!['car_type']),
          _buildDetailTile(Icons.pin, 'Car Registration', _driverData!['car_reg_number']),
          _buildDetailTile(Icons.badge, 'License Number', _driverData!['license_number']),
          _buildDetailTile(Icons.event, 'License Expiry', _driverData!['license_expiry']),
          const SizedBox(height: 30),
          ElevatedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50), // full width
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                  ),
              ),
          )
        ],
      ),
    );
  }

  // Helper widget to avoid repeating code for each detail
  Widget _buildDetailTile(IconData icon, String title, String? value) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: const TextStyle(color: Colors.white54)),
        subtitle: Text(
          value ?? 'Not provided',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}