import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/incident_service.dart';

class IncidentStatusScreen extends StatelessWidget {
  final String incidentId;

  const IncidentStatusScreen({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context) {
    final IncidentService incidentService = IncidentService();

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Status')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('incidents')
            .doc(incidentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final Map<String, dynamic>? data = snapshot.data!.data();

          if (data == null) {
            return const Center(child: Text('Incident not found.'));
          }

          final String status = data['status'] ?? 'unknown';

          String message;

          if (status == 'guardian_alert_sent') {
            message = 'Nearby guardians have been notified.';
          } else if (status == 'guardian_responding') {
            message = 'A verified guardian is responding.';
          } else if (status == 'escalated') {
            message = 'Your emergency contacts have been alerted.';
          } else if (status == 'resolved') {
            message = 'You are marked safe. Incident closed.';
          } else {
            message = 'Waiting for update...';
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    status == 'resolved'
                        ? Icons.verified_user
                        : Icons.notifications_active,
                    size: 90,
                    color: status == 'resolved'
                        ? Colors.greenAccent
                        : const Color(0xFF00E5FF),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (status != 'resolved')
                    Column(
                      children: [
                        if (status == 'guardian_responding')
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF),
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              try {
                                await incidentService
                                    .shareExactLocationWithGuardian(
                                  incidentId: incidentId,
                                );

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Your exact location has been shared with the responding guardian.',
                                    ),
                                  ),
                                );
                              } catch (error) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error.toString()),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.location_on),
                            label: const Text('Share My Exact Location'),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await incidentService.escalateIncident(
                              incidentId: incidentId,
                            );
                          },
                          icon: const Icon(Icons.warning),
                          label: const Text('Escalate Emergency'),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await incidentService.markUserSafe(
                              incidentId: incidentId,
                            );
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('I Am Safe'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
