class Users {
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

  Users(
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
  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      userId: json['user_id'],
      userName: json['user_mame'],
      userIconUrl: json['user_icon_url'],
      selfIntroduce: json['self_introduce'],
      favoriteGyms: json['favorite_gym'],
      boulStartDate: json['boul_Start_Date'],
      homeGymId: json['home_gym_id'],
      email: json['email'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
  List<Users> parseUsersList(List<dynamic> jsonList) {
    return jsonList.map((json) => Users.fromJson(json)).toList();
  }
}
