import 'package:flutter/material.dart';

class SelectCarPage extends StatelessWidget {
  const SelectCarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Select Car Type',
          style: TextStyle(color: Colors.amber),
        ),
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            RideCard(
              icon: Icons.directions_car,
              label: 'Sedan',
              cost: 150,
              distance: '5.2 km',
            ),
            RideCard(
              icon: Icons.sports_motorsports,
              label: 'SUV',
              cost: 200,
              distance: '5.2 km',
            ),
            RideCard(
              icon: Icons.electric_car,
              label: 'EV',
              cost: 180,
              distance: '5.2 km',
            ),
            RideCard(
              icon: Icons.local_taxi,
              label: 'Taxi',
              cost: 130,
              distance: '5.2 km',
            ),
          ],
        ),
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int cost;
  final String distance;

  const RideCard({
    super.key,
    required this.icon,
    required this.label,
    required this.cost,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber, size: 36),
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 20)),
        subtitle: Text('Distance: $distance', style: const TextStyle(color: Colors.white70)),
        trailing: Text(
          '₹$cost',
          style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          // You can add navigation or selection logic here later
        },
      ),
    );
  }
}
