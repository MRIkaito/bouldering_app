class BoulLogTweet {
  final int tweetId;
  final String userId;
  final String userName;
  final String userIconUrl;
  final DateTime visitedDate;
  final DateTime tweetedDate;
  final int gymId;
  final String tweetContents;
  final int likedCount;
  final String? movieUrl;
  final String gymName;
  final String prefecture;
  final List<String> mediaUrls;

  BoulLogTweet({
    required this.tweetId,
    required this.userId,
    required this.userName,
    required this.userIconUrl,
    required this.visitedDate,
    required this.tweetedDate,
    required this.gymId,
    required this.tweetContents,
    required this.likedCount,
    required this.movieUrl,
    required this.gymName,
    required this.prefecture,
    required this.mediaUrls,
  });

  factory BoulLogTweet.fromJson(Map<String, dynamic> json) {
    return BoulLogTweet(
      tweetId: json['tweet_id'] ?? 0,
      tweetContents: json['tweet_contents'] ?? '',
      visitedDate:
          DateTime.tryParse(json['visited_date'] ?? '') ?? DateTime(1990, 1, 1),
      tweetedDate:
          DateTime.tryParse(json['tweeted_date'] ?? '') ?? DateTime(1990, 1, 1),
      likedCount: json['liked_counts'] ?? 0,
      movieUrl: json['movie_url'],
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userIconUrl: json['user_icon_url'] ?? '',
      gymId: json['gym_id'] ?? 0,
      gymName: json['gym_name'] ?? '',
      prefecture: json['prefecture'] ?? '',
      mediaUrls: List<String>.from(json['media_urls'] ?? []),
    );
  }

  // ヘルパー関数:List<dynanic> → List<BoulLogTweet>に変換
  List<BoulLogTweet> parseBoulLogTweetList(List<dynamic> jsonList) {
    return jsonList.map((json) => BoulLogTweet.fromJson(json)).toList();
  }

  /// ■ メソッド
  /// - 状態変更を反映するメソッド
  ///
  /// 引数
  /// - 各プロパティ
  ///
  /// 返り値
  /// - もらった引数を反映した状態
  BoulLogTweet copyWith({
    int? tweetId,
    String? tweetContents,
    DateTime? visitedDate,
    DateTime? tweetedDate,
    int? likedCount,
    String? movieUrl,
    String? userId,
    String? userName,
    String? userIconUrl,
    int? gymId,
    String? gymName,
    String? prefecture,
    List<String>? mediaUrls,
  }) {
    return BoulLogTweet(
      tweetId: tweetId ?? this.tweetId,
      tweetContents: tweetContents ?? this.tweetContents,
      visitedDate: visitedDate ?? this.visitedDate,
      tweetedDate: tweetedDate ?? this.tweetedDate,
      likedCount: likedCount ?? this.likedCount,
      movieUrl: movieUrl ?? this.movieUrl,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userIconUrl: userIconUrl ?? this.userIconUrl,
      gymId: gymId ?? this.gymId,
      gymName: gymName ?? this.gymName,
      prefecture: prefecture ?? this.prefecture,
      mediaUrls: mediaUrls ?? this.mediaUrls,
    );
  }
}
