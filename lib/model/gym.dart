class Gym {
  final String gymName;
  final double latitude;
  final double longitude;
  final String prefecture;
  final String city;

  Gym({
    required this.gymName,
    required this.latitude,
    required this.longitude,
    required this.prefecture,
    required this.city,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      gymName: (json['gymName'] as String?) ?? 'ジム名なし',
      latitude: ((json['latitude'] ?? 0) as num).toDouble(),
      longitude: ((json['longitude'] ?? 0) as num).toDouble(),
      prefecture: (json['prefecture'] as String?) ?? '○○県',
      city: (json['city'] as String?) ?? '○○市',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gymName': gymName,
      'latitude': latitude,
      'longitude': longitude,
      'prefecture': prefecture,
      'city': city,
    };
  }
}
