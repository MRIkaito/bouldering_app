class User {
  final String userId;
  final String userName;
  final String userIconUrl;
  final String selfIntroduce;
  final String favoriteGym;
  final DateTime boulStartYearAndMonth;
  final String homeGymId;
  final String mailAddress;
  final String firebaseUuid;

  User({
    required this.userId,
    required this.userName,
    required this.userIconUrl,
    required this.selfIntroduce,
    required this.favoriteGym,
    required this.boulStartYearAndMonth,
    required this.homeGymId,
    required this.mailAddress,
    required this.firebaseUuid,
  });

  // JSON形式からUserクラスへの変換
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      userName: json['userName'],
      userIconUrl: json['userIconUrl'],
      selfIntroduce: json['selfIntroduce'],
      favoriteGym: json['favoriteGym'],
      boulStartYearAndMonth: json['boulStartYearAndMonth'],
      homeGymId: json['homeGymId'],
      mailAddress: json['mailAddress'],
      firebaseUuid: json['firebaseUuid'],
    );
  }

  // UserクラスからJSON形式への変換
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userIconUrl': userIconUrl,
      'selfIntroduce': selfIntroduce,
      'favoriteGym': favoriteGym,
      'boulStartYearAndMonth': boulStartYearAndMonth,
      'homeGymId': homeGymId,
      'mailAddress': mailAddress,
      'firebaseUuid': firebaseUuid,
    };
  }
}
