import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'setup_customer_profile_page.dart';
import 'edit_customer_profile_page.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _customerData;
  String? _error;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCustomerProfile();
  }

  Future<void> _fetchCustomerProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (_user == null) {
      setState(() {
        _error = "You are not logged in.";
        _isLoading = false;
      });
      return;
    }

    try {
      final idToken = await _user!.getIdToken(true);
      final url = Uri.parse('http://10.187.64.208:3000/api/customers/profile');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $idToken'},
      );

      if (mounted) {
        if (response.statusCode == 200) {
          setState(() {
            _customerData = json.decode(response.body);
          });
        } else if (response.statusCode != 404) {
          setState(() {
            _error = "Failed to load profile. Status: ${response.statusCode}";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "An error occurred: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  void _navigateToSetup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SetupCustomerProfilePage()),
    );
    if (result == true) {
      _fetchCustomerProfile();
    }
  }

  void _navigateToEdit() async {
    if (_customerData == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerProfilePage(customerData: _customerData!),
      ),
    );
    if (result == true) {
      _fetchCustomerProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.grey[850],
        automaticallyImplyLeading: false,
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
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    // If data exists, show the profile. Otherwise, show the setup prompt.
    return _customerData != null ? _buildProfileView() : _buildSetupView();
  }

  Widget _buildProfileView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            color: Colors.grey[800],
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.amber, size: 40),
              title: Text(_customerData!['name'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 22)),
              subtitle: Text(_customerData!['email'] ?? 'N/A', style: const TextStyle(color: Colors.white70)),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.grey[800],
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.amber),
              title: const Text('Phone', style: TextStyle(color: Colors.white54)),
              subtitle: Text(_customerData!['phone'] ?? 'N/A', style: const TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _navigateToEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSetupView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.person_add_alt_1, color: Colors.amber, size: 80),
          const SizedBox(height: 20),
          const Text(
            'Complete Your Profile',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Logged in as ${_user?.email ?? "..."}\n\nPlease set up your profile to continue.',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _navigateToSetup,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Complete Profile', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
