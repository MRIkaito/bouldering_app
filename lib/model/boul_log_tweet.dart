// class BoulLogTweet {
//   final int tweetId;
//   final String userId;
//   final DateTime visitedDate;
//   final DateTime tweetedDate; // createdDateと同じ意味
//   final int gymId;
//   final String tweetContents;
//   final int likedCount;
//   final String movieUrl;

//   BoulLogTweet(
//       {required this.tweetId,
//       required this.userId,
//       required this.visitedDate,
//       required this.tweetedDate,
//       required this.gymId,
//       required this.tweetContents,
//       required this.likedCount,
//       required this.movieUrl});

//   // JSON形式からBoulLogTweetクラス(Map形式)への変換
//   factory BoulLogTweet.fromJson(Map<String, dynamic> json) {
//     return BoulLogTweet(
//         tweetId: json['tweet_id'],
//         userId: json['user_id'],
//         visitedDate: json['visited_date'],
//         tweetedDate: json['tweeted_date'],
//         gymId: json['gym_id'],
//         tweetContents: json['tweet_contents'],
//         likedCount: json['liked_count'],
//         movieUrl: json['movie_url']);
//   }

//   // BoulLogTweetクラスからJSON形式への変換
//   Map<String, dynamic> toJson() {
//     return {
//       'tweet_id': tweetId,
//       'user_id': userId,
//       'visited_date': visitedDate,
//       'tweeted_date': tweetedDate,
//       'gym_id': gymId,
//       'tweet_contents': tweetContents,
//       'liked_count': likedCount,
//       'movie_url': movieUrl
//     };
//   }

//   // ヘルパー関数:List<dynanic> → List<BoulLogTweet>に変換
//   List<BoulLogTweet> parseBoulLogTweetList(List<dynamic> jsonList) {
//     return jsonList.map((json) => BoulLogTweet.fromJson(json)).toList();
//   }
// }

class BoulLogTweet {
  final int tweetId;
  final String userId;
  final String userName;
  final DateTime visitedDate;
  final DateTime tweetedDate; // createdAtと同義
  final int gymId;
  final String tweetContents;
  final int likedCount;
  final String? movieUrl;
  final String gymName;
  final String prefecture;

  BoulLogTweet({
    required this.tweetId,
    required this.userId,
    required this.userName,
    required this.visitedDate,
    required this.tweetedDate,
    required this.gymId,
    required this.tweetContents,
    required this.likedCount,
    required this.movieUrl,
    required this.gymName,
    required this.prefecture,
  });

  // JSON形式からBoulLogTweetクラス(Map形式)への変換
  factory BoulLogTweet.fromJson(Map<String, dynamic> json) {
    print(
        "🔍 visited_date raw: ${json['visited_date']} | type: ${json['visited_date'].runtimeType}");
    return BoulLogTweet(
      tweetId: json['tweet_id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      visitedDate: DateTime.parse(json['visited_date'] ?? '1990-01-01'),
      tweetedDate: DateTime.parse(json['tweeted_date'] ?? '1990-01-01'),
      gymId: json['gym_id'] ?? 0,
      tweetContents: json['tweet_contents'] ?? '',
      likedCount: json['liked_count'] ?? 0,
      movieUrl: json['movie_url'] ?? '',
      gymName: json['gym_name'] ?? '',
      prefecture: json['prefecture'] ?? '',
    );
  }

  // BoulLogTweetクラスからJSON形式への変換
  Map<String, dynamic> toJson() {
    return {
      'tweet_id': tweetId,
      'user_id': userId,
      'user_name': userName,
      'visited_date': visitedDate,
      'tweeted_date': tweetedDate,
      'gym_id': gymId,
      'tweet_contents': tweetContents,
      'liked_count': likedCount,
      'movie_url': movieUrl,
      'gym_name': gymName,
      'prefecture': prefecture,
    };
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
    int? gymId,
    String? gymName,
    String? prefecture,
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
      gymId: gymId ?? this.gymId,
      gymName: gymName ?? this.gymName,
      prefecture: prefecture ?? this.prefecture,
    );
  }
}
