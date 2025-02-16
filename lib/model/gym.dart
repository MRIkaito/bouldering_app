class Gym {
  final int gymId;
  final String gymName;
  final double latitude;
  final double longitude;

  Gym({
    required this.gymId,
    required this.gymName,
    required this.latitude,
    required this.longitude,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      gymId: (json['gymId'] as int?) ?? 0,
      gymName: (json['gymName'] as String?) ?? 'ジム名なし',
      latitude: ((json['latitude'] ?? 0) as num).toDouble(),
      longitude: ((json['longitude'] ?? 0) as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gymId': gymId,
      'gymName': gymName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
