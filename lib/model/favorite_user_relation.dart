class FavoriteUserRelation {
  final String likerUserId;
  final String likeeUserId;

  FavoriteUserRelation({
    required this.likerUserId,
    required this.likeeUserId,
  });

  // JSON形式からFavoriteUserRelationクラスへの変換
  factory FavoriteUserRelation.fromJson(Map<String, dynamic> json) {
    return FavoriteUserRelation(
        likerUserId: json['liker_user_id'], likeeUserId: json['likee_user_id']);
  }
}
