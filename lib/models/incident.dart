class Incident {
  final String incidentId;
  final String userUid;
  final String status;
  final double latitude;
  final double longitude;
  final String zone;
  final bool escalated;
  final bool resolved;
  final bool exactLocationShared;

  const Incident({
    required this.incidentId,
    required this.userUid,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.zone,
    required this.escalated,
    required this.resolved,
    required this.exactLocationShared,
  });

  factory Incident.fromMap(String id, Map<String, dynamic> data) {
    return Incident(
      incidentId: data['incidentId'] ?? id,
      userUid: data['userUid'] ?? '',
      status: data['status'] ?? 'unknown',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      zone: data['zone'] ?? '',
      escalated: data['escalated'] ?? false,
      resolved: data['resolved'] ?? false,
      exactLocationShared: data['exactLocationShared'] ?? false,
    );
  }
}
