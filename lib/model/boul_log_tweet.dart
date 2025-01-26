class BoulLogTweet {
  final int tweetId;
  final String userId;
  final DateTime visitedDate;
  final DateTime tweetedDate; // createdDateと同じ意味
  final int gymId;
  final String tweetContents;
  final int likedCount;
  final String movieUrl;

  BoulLogTweet(
      {required this.tweetId,
      required this.userId,
      required this.visitedDate,
      required this.tweetedDate,
      required this.gymId,
      required this.tweetContents,
      required this.likedCount,
      required this.movieUrl});

  // JSON形式からBoulLogTweetクラス(Map形式)への変換
  factory BoulLogTweet.fromJson(Map<String, dynamic> json) {
    return BoulLogTweet(
        tweetId: json['tweet_id'],
        userId: json['user_id'],
        visitedDate: json['visited_date'],
        tweetedDate: json['tweeted_date'],
        gymId: json['gym_id'],
        tweetContents: json['tweet_contents'],
        likedCount: json['liked_count'],
        movieUrl: json['movie_url']);
  }

  // BoulLogTweetクラスからJSON形式への変換
  Map<String, dynamic> toJson() {
    return {
      'tweet_id': tweetId,
      'user_id': userId,
      'visited_date': visitedDate,
      'tweeted_date': tweetedDate,
      'gym_id': gymId,
      'tweet_contents': tweetContents,
      'liked_count': likedCount,
      'movie_url': movieUrl
    };
  }

  // ヘルパー関数:List<dynanic> → List<BoulLogTweet>に変換
  List<BoulLogTweet> parseBoulLogTweetList(List<dynamic> jsonList) {
    return jsonList.map((json) => BoulLogTweet.fromJson(json)).toList();
  }
}
