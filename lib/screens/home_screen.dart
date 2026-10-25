import 'package:flutter/material.dart';

import 'sos_screen.dart';
import '../services/shake_service.dart';
import '../widgets/sos_button.dart';
import '../widgets/safety_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ShakeService _shakeService = ShakeService();

  @override
  void initState() {
    super.initState();

    _shakeService.startListening(
      onShakeDetected: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SosScreen()),
        );
      },
    );
  }

  @override
  void dispose() {
    _shakeService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SafeChain'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'You are protected',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Shake your phone three times or press SOS to alert nearby verified guardians.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 48),
              SosButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SosScreen()),
                  );
                },
              ),
              const SizedBox(height: 48),
              Row(
                children: [
                  Expanded(
                    child: SafetyCard(
                      icon: Icons.phone_in_talk,
                      title: 'Fake Call',
                      subtitle: 'Create an emergency exit call',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SafetyCard(
                      icon: Icons.location_on,
                      title: 'Safe Check-In',
                      subtitle: 'Let contacts know you are safe',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
