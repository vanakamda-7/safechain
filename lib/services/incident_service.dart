import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

import 'location_service.dart';

class IncidentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();
  final LocationService _locationService = LocationService();

  Future<String> createSosIncident({
    required Position position,
    required String zoneId,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final String incidentId =
        'INC_${_uuid.v4().substring(0, 8).toUpperCase()}';

    await _firestore.collection('incidents').doc(incidentId).set({
      'incidentId': incidentId,
      'userUid': user.uid,
      'status': 'guardian_alert_sent',
      'latitude': position.latitude,
      'longitude': position.longitude,
      'zone': zoneId,
      'createdAt': FieldValue.serverTimestamp(),
      'guardianUid': '',
      'escalated': false,
      'resolved': false,
      'exactLocationShared': false,
    });

    await _notifyNearbyGuardians(
      incidentId: incidentId,
      position: position,
      zoneId: zoneId,
    );

    return incidentId;
  }

  Future<void> _notifyNearbyGuardians({
    required String incidentId,
    required Position position,
    required String zoneId,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> guardians =
        await _firestore
            .collection('guardians')
            .where('isAvailable', isEqualTo: true)
            .where('verified', isEqualTo: true)
            .get();

    for (final QueryDocumentSnapshot<Map<String, dynamic>> guardian
        in guardians.docs) {
      final Map<String, dynamic> data = guardian.data();

      final double? guardianLatitude = data['latitude'] as double?;
      final double? guardianLongitude = data['longitude'] as double?;

      if (guardianLatitude == null || guardianLongitude == null) {
        continue;
      }

      final double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        guardianLatitude,
        guardianLongitude,
      );

      if (distance <= 500) {
        await guardian.reference
            .collection('alerts')
            .doc(incidentId)
            .set({
          'incidentId': incidentId,
          'zone': zoneId,
          'message': 'A verified user needs assistance nearby.',
          'status': 'pending',
          'exactLocationShared': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> acceptIncident({
    required String incidentId,
    required String guardianUid,
  }) async {
    await _firestore.collection('incidents').doc(incidentId).update({
      'status': 'guardian_responding',
      'guardianUid': guardianUid,
    });

    await _firestore
        .collection('incident_responses')
        .doc('${incidentId}_$guardianUid')
        .set({
      'incidentId': incidentId,
      'guardianUid': guardianUid,
      'action': 'accepted',
      'responseTime': FieldValue.serverTimestamp(),
    });
  }

  Future<void> shareExactLocationWithGuardian({
    required String incidentId,
  }) async {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final Position? position =
        await _locationService.getCurrentLocation();

    if (position == null) {
      throw Exception('Location permission is required.');
    }

    await _firestore.collection('incidents').doc(incidentId).update({
      'sharedLatitude': position.latitude,
      'sharedLongitude': position.longitude,
      'exactLocationShared': true,
      'locationSharedAt': FieldValue.serverTimestamp(),
    });

    final DocumentSnapshot<Map<String, dynamic>> incidentSnapshot =
        await _firestore.collection('incidents').doc(incidentId).get();

    final String? guardianUid =
        incidentSnapshot.data()?['guardianUid'] as String?;

    if (guardianUid != null && guardianUid.isNotEmpty) {
      await _firestore
          .collection('guardians')
          .doc(guardianUid)
          .collection('alerts')
          .doc(incidentId)
          .update({
        'exactLocationShared': true,
        'sharedLatitude': position.latitude,
        'sharedLongitude': position.longitude,
      });
    }
  }

  Future<void> markUserSafe({
    required String incidentId,
  }) async {
    await _firestore.collection('incidents').doc(incidentId).update({
      'status': 'resolved',
      'resolved': true,
    });
  }

  Future<void> escalateIncident({
    required String incidentId,
  }) async {
    await _firestore.collection('incidents').doc(incidentId).update({
      'status': 'escalated',
      'escalated': true,
    });
  }
}
