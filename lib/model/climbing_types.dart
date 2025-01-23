class ClimbingTypes {
  final int gymId;
  final bool isBoulderingGym;
  final bool isLeadGym;
  final bool isSpeedGym;

  ClimbingTypes(
      {required this.gymId,
      required this.isBoulderingGym,
      required this.isLeadGym,
      required this.isSpeedGym});

  // JSON形式からClimbingTypesクラスへの変換
  factory ClimbingTypes.fromJson(Map<String, dynamic> json) {
    return ClimbingTypes(
        gymId: json['gym_id'],
        isBoulderingGym: json['is_bouldering_gym'],
        isLeadGym: json['is_lead_gym'],
        isSpeedGym: json['is_speed_gym']);
  }

  // ClimbingTypesクラスからJSON形式への変換
  Map<String, dynamic> toJson() {
    return {
      'gym_id': gymId,
      'is_bouldering_gym': isBoulderingGym,
      'is_lead_gym': isLeadGym,
      'is_speed_gym': isSpeedGym,
    };
  }

  // ヘルパー関数:List<dynamic> → List<ClimbingTypes>に変換する
  List<ClimbingTypes> parseClimbingTypesList(List<dynamic> jsonList) {
    return jsonList.map((json) => ClimbingTypes.fromJson(json)).toList();
  }
}
