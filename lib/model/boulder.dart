class Boulder {
  final String userId;
  final String userName;
  final String userIconUrl;
  final String userIntroduce;
  final String favoriteGym;
  final DateTime boulStartDate;
  final int homeGymId;
  final String email;
  final DateTime birthday;
  final int gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  Boulder({
    required this.userId,
    required this.userName,
    required this.userIconUrl,
    required this.userIntroduce,
    required this.favoriteGym,
    required this.boulStartDate,
    required this.homeGymId,
    required this.email,
    required this.birthday,
    required this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  // JSON形式からUserクラスへの変換
  factory Boulder.fromJson(Map<String, dynamic> json) {
    return Boulder(
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userIconUrl: json['user_icon_url'] ?? '',
      userIntroduce: json['user_introduce'] ?? '',
      favoriteGym: json['favorite_gym'] ?? '',
      boulStartDate: json['boul_start_date'] != null
          ? DateTime.parse(json['boul_start_date']) // DateTime.parse を適用
          : DateTime.now(),
      homeGymId: json['home_gym_id'] ?? 0, // nullの場合は0にする
      email: json['email'] ?? '',
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : DateTime.now(), // nullの場合、点在時刻をデフォルト値とする
      gender: (json['gender'] is String)
          ? (json['gender'] == '0' ||
                  json['gender'] == '1' ||
                  json['gender'] == '2')
              ? int.parse(json['gender']) // 0, 1, 2 なら変換
              : 0 // それ以外の文字列は 0
          : (json['gender'] is int &&
                  (json['gender'] == 0 ||
                      json['gender'] == 1 ||
                      json['gender'] == 2))
              ? json['gender'] // 0, 1, 2 の整数ならそのまま使う
              : 0, // それ以外(nullもここに該当)
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
      'user_introduce': userIntroduce,
      'favorite_gym': favoriteGym,
      'boul_start_date': boulStartDate,
      'home_gym_id': homeGymId,
      'email': email,
      'birthday': birthday,
      'gender': gender,
      'created_at': createdAt,
      'updated_at': updatedAt
    };
  }

  /// ■メソッド
  /// - 状態更新の通知を行うために，Stateに更新した値をコピーする
  ///
  /// - 引数
  /// 各プロパティ値で，更新するもの
  ///
  /// - 返り値
  /// 更新したBoulderクラスの状態(インスタンス)
  Boulder copyWith({
    String? userId,
    String? userName,
    String? userIconUrl,
    String? userIntroduce,
    String? favoriteGym,
    DateTime? boulStartDate,
    int? homeGymId,
    String? email,
    DateTime? birthday,
    int? gender,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Boulder(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userIconUrl: userIconUrl ?? this.userIconUrl,
      userIntroduce: userIntroduce ?? this.userIntroduce,
      favoriteGym: favoriteGym ?? this.favoriteGym,
      boulStartDate: boulStartDate ?? this.boulStartDate,
      homeGymId: homeGymId ?? this.homeGymId,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ヘルパ関数：List<dynamic> → List<Users>に変換する
  List<Boulder> parseUsersList(List<dynamic> jsonList) {
    return jsonList.map((json) => Boulder.fromJson(json)).toList();
  }
}
