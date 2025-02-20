class Boulder {
  final String userId;
  final String userName;
  final String userIconUrl;
  final String selfIntroduce;
  final String favoriteGyms;
  final DateTime boulStartDate;
  final int homeGymId;
  final String email;
  final DateTime birthday;
  final int gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  Boulder(
      {required this.userId,
      required this.userName,
      required this.userIconUrl,
      required this.selfIntroduce,
      required this.favoriteGyms,
      required this.boulStartDate,
      required this.homeGymId,
      required this.email,
      required this.birthday,
      required this.gender,
      required this.createdAt,
      required this.updatedAt});

  // JSON形式からUserクラスへの変換
  factory Boulder.fromJson(Map<String, dynamic> json) {
    return Boulder(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userIconUrl: json['user_icon_url'] ?? '',
      selfIntroduce: json['self_introduce'] ?? '',
      favoriteGyms: json['favorite_gym'] ?? '',
      boulStartDate: json['boul_start_date'] != null
          ? DateTime.parse(json['boul_start_date']) // DateTime.parse を適用
          : DateTime.now(),
      homeGymId: json['home_gym_id'] ?? 0, // nullの場合は0にする
      email: json['email'] ?? '',
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : DateTime.now(), // nullの場合、点在時刻をデフォルト値とする
      gender: switch (json['gender']) {
        '0' || '1' || '2' => int.parse(json['gender']),
        _ => 0
      },
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(), // nullの場合、現在時刻をデフォルト値とする
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(), // nullの場合、現在時刻をデフォルト値とする
    );
  }

  // UserクラスからJSON形式への変換
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_icon_url': userIconUrl,
      'self_introduce': selfIntroduce,
      'favorite_gym': favoriteGyms,
      'boul_start_date': boulStartDate,
      'home_gym_id': homeGymId,
      'email': email,
      'birthday': birthday,
      'gender': gender,
      'created_at': createdAt,
      'updated_at': updatedAt
    };
  }

  // ヘルパ関数：List<dynamic> → List<Users>に変換する
  List<Boulder> parseUsersList(List<dynamic> jsonList) {
    return jsonList.map((json) => Boulder.fromJson(json)).toList();
  }
}
