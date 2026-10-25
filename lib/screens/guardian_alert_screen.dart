import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/incident_service.dart';

class GuardianAlertScreen extends StatelessWidget {
  const GuardianAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final IncidentService incidentService = IncidentService();

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in as a guardian.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Alerts')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('guardians')
            .doc(user.uid)
            .collection('alerts')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data!.docs;

          if (alerts.isEmpty) {
            return const Center(child: Text('No active alerts nearby.'));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index].data();

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: const Icon(
                    Icons.emergency,
                    color: Colors.redAccent,
                  ),
                  title: Text(
                    alert['message'] ??
                        'A verified user needs assistance nearby.',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Zone: ${alert['zone'] ?? 'Unknown'}'),
                      if (alert['exactLocationShared'] == true)
                        Text(
                          'Exact location shared: '
                          '${alert['sharedLatitude']}, '
                          '${alert['sharedLongitude']}',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        const Text(
                          'Exact location not shared yet.',
                        ),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      await incidentService.acceptIncident(
                        incidentId: alert['incidentId'],
                        guardianUid: user.uid,
                      );

                      await alerts[index].reference.update({
                        'status': 'accepted',
                      });
                    },
                    child: const Text('Accept'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
