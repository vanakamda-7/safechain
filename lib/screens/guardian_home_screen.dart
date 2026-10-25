import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'guardian_alert_screen.dart';
import '../services/location_service.dart';

class GuardianHomeScreen extends StatefulWidget {
  const GuardianHomeScreen({super.key});

  @override
  State<GuardianHomeScreen> createState() => _GuardianHomeScreenState();
}

class _GuardianHomeScreenState extends State<GuardianHomeScreen> {
  final LocationService _locationService = LocationService();

  bool _isAvailable = true;
  bool _isLoading = false;

  Future<void> _updateAvailability(bool value) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      _isAvailable = value;
      _isLoading = true;
    });

    Position? position;

    if (value) {
      position = await _locationService.getCurrentLocation();
    }

    await FirebaseFirestore.instance
        .collection('guardians')
        .doc(user.uid)
        .update({
      'isAvailable': value,
      if (position != null) 'latitude': position.latitude,
      if (position != null) 'longitude': position.longitude,
    });

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guardian Dashboard')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.health_and_safety,
                size: 80,
                color: Color(0xFF00E5FF),
              ),
              const SizedBox(height: 24),
              const Text(
                'Guardian Mode',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Available for alerts'),
                subtitle: const Text(
                  'Enable this to receive nearby emergency alerts.',
                ),
                value: _isAvailable,
                onChanged: _isLoading ? null : _updateAvailability,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const GuardianAlertScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications_active),
                label: const Text('View Nearby Alerts'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
