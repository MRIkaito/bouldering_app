class BoulLogTweetPhoto {
  final int photoId;
  final int tweetId;
  final String photoUrl;

  BoulLogTweetPhoto(
      {required this.photoId, required this.tweetId, required this.photoUrl});

  // JSON形式からBoulLogTweetクラス(Map形式)への変換
  factory BoulLogTweetPhoto.fromJson(Map<String, dynamic> json) {
    return BoulLogTweetPhoto(
        photoId: json['photo_id'],
        tweetId: json['tweet_id'],
        photoUrl: json['photo_url']);
  }

  // BoulLogTweetクラスからJSON形式への変換
  Map<String, dynamic> toJson() {
    return {
      'photo_id': photoId,
      'tweet_id': tweetId,
      'photo_url': photoUrl,
    };
  }

  // ヘルパ関数：List<dynamic> → List<BoulLogTweetPhoto>に変換する処理を追加する
  List<BoulLogTweetPhoto> parseBoulLogTweetList(List<dynamic> jsonList) {
    return jsonList.map((json) => BoulLogTweetPhoto.fromJson(json)).toList();
  }
}
