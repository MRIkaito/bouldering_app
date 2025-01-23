class WannaGoRelation {
  final String userId;
  final int gymId;

  WannaGoRelation({
    required this.userId,
    required this.gymId,
  });

  // JSON形式からWannaGoRelationクラスへの変換
  factory WannaGoRelation.fromJson(Map<String, dynamic> json) {
    return WannaGoRelation(
      userId: json['user_id'],
      gymId: json['gym_id'],
    );
  }

  // WannaGoRelationクラスからJSON形式への変換
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'gym_id': gymId,
    };
  }

  // ヘルパ関数：List<dynamic> → List<WannaGoRelation>に変換
  List<WannaGoRelation> parseWannaGoRelatioList(List<dynamic> jsonList) {
    return jsonList.map((json) => WannaGoRelation.fromJson(json)).toList();
  }
}
