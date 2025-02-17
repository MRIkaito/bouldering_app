class Gym {
  final int gymId;
  final String gymName;
  final double latitude;
  final double longitude;
  final String prefecture;
  final String city;

  Gym({
    required this.gymId,
    required this.gymName,
    required this.latitude,
    required this.longitude,
    required this.prefecture,
    required this.city,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      gymId: (json['gym_id'] as int?) ?? 0,
      gymName: (json['gym_name'] as String?) ?? 'ジム名なし',
      latitude: (json['latitude'] is double)
          ? json['latitude']
          : double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: (json['longitude'] is double)
          ? json['longitude']
          : double.tryParse(json['longitude'].toString()) ?? 0.0,
      prefecture: (json['prefecture'] as String?) ?? '○○県',
      city: (json['city'] as String?) ?? '○○市',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gym_id': gymId,
      'gym_name': gymName,
      'latitude': latitude,
      'longitude': longitude,
      'prefecture': prefecture,
      'city': city,
    };
  }
}
