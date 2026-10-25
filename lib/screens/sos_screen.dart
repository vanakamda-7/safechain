import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'incident_status_screen.dart';
import '../services/incident_service.dart';
import '../services/location_service.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final LocationService _locationService = LocationService();
  final IncidentService _incidentService = IncidentService();

  bool _isLoading = false;

  Future<void> _triggerSos() async {
    setState(() => _isLoading = true);

    final Position? position =
        await _locationService.getCurrentLocation();

    if (!mounted) return;

    if (position == null) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required for SOS.'),
        ),
      );
      return;
    }

    try {
      final String zoneId = _locationService.createZoneId(position);

      final String incidentId =
          await _incidentService.createSosIncident(
        position: position,
        zoneId: zoneId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => IncidentStatusScreen(incidentId: incidentId),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Assistance')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 90,
                color: Color(0xFF00E5FF),
              ),
              const SizedBox(height: 24),
              const Text(
                'Do you need immediate help?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Nearby verified guardians will receive an anonymous alert. Your exact location will not be shared unless you choose to share it.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      onPressed: _triggerSos,
                      icon: const Icon(Icons.emergency),
                      label: const Text(
                        'SEND SOS ALERT',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
