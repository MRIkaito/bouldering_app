class GymPhoto {
  final int gymPhotoId;
  final int gymId;
  final String gymPhotoUrl;

  GymPhoto({
    required this.gymPhotoId,
    required this.gymId,
    required this.gymPhotoUrl,
  });

  // JSON形式からGymPhotoクラスへの変換
  factory GymPhoto.fromJson(Map<String, dynamic> json) {
    return GymPhoto(
      gymPhotoId: json['gym_photo_id'],
      gymId: json['gym_id'],
      gymPhotoUrl: json['gym_photo_url'],
    );
  }

  // GymPhotoクラスからJSON形式への変換
  Map<String, dynamic> toJson() {
    return {
      'gym_photo_id': gymPhotoId,
      'gym_id': gymId,
      'gym_photo_url': gymPhotoUrl,
    };
  }

  // ヘルパ関数：List<dynamic> → List<GymPhoto>に変換する
  List<GymPhoto> parseGymPhotoList(List<dynamic> jsonList) {
    return jsonList.map((json) => GymPhoto.fromJson(json)).toList();
  }
}
