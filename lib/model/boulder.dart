class Boulder {
  final String userId;
  final String userName;
  final String userIconUrl;
  final String selfIntroduce;
  final String favoriteGyms;
  final DateTime boulStartDate;
  final int homeGymId;
  final String email;
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
      required this.createdAt,
      required this.updatedAt});

  // JSON形式からUserクラスへの変換
  factory Boulder.fromJson(Map<String, dynamic> json) {
    return Boulder(
      userId: json['user_id'] ?? '', // Null の場合は空文字
      userName: json['user_name'] ?? '', // 【修正】キーのスペルミスを修正
      userIconUrl: json['user_icon_url'] ?? '',
      selfIntroduce: json['self_introduce'] ?? '',
      favoriteGyms: json['favorite_gym'] ?? '',
      boulStartDate: json['boul_start_date'] != null
          ? DateTime.parse(json['boul_start_date']) // 【修正】DateTime.parse を適用
          : DateTime.now(), // デフォルト値：(ToDo)この部分の処理を理解する
      homeGymId: json['home_gym_id'] ?? 0, // 【修正】nullの場合は0にする,
      email: json['email'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']) // 【修正】DateTime.parse を適用
          : DateTime.now(), // デフォルト値
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']) // 【修正】DateTime.parse を適用
          : DateTime.now(), // デフォルト値
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
      'created_at': createdAt,
      'updated_at': updatedAt
    };
  }

  // ヘルパ関数：List<dynamic> → List<Users>に変換する
  List<Boulder> parseUsersList(List<dynamic> jsonList) {
    return jsonList.map((json) => Boulder.fromJson(json)).toList();
  }
}
