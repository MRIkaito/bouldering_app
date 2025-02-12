class MyOwnTweets {
  String tweetId; // TODO：ツイートIDがStringかintか確認する
  String tweetContents;
  String visitedDate;
  String tweetedDate;
  int likedCount;
  String movieUrl;
  String userId;
  String userName;
  String userIconUrl;
  int gymId;
  String gymName;
  String prefecture;

  MyOwnTweets(
      {this.tweetId = '',
      this.tweetContents = '',
      this.visitedDate = '1990-01-01',
      this.tweetedDate = '1990-01-01',
      this.likedCount = 0,
      this.movieUrl = '',
      this.userId = '',
      this.userName = '',
      this.userIconUrl = '',
      this.gymId = 0,
      this.gymName = '',
      this.prefecture = ''});

  // JSON形式からUserクラスへの変換
  // factory List<MyOwnTweet> MyOwnTweet.fromJson(List<Map<String, dynamic>> json) {
  factory MyOwnTweets.fromJson(Map<String, dynamic> json) {
    return MyOwnTweets(
      tweetId: json['tweet_id'] ?? '',
      tweetContents: json['tweet_contents'] ?? '',
      visitedDate: DateTime.parse(json['visited_date'])
          .toLocal()
          .toString()
          .split(' ')[0],
      tweetedDate: DateTime.parse(json['tweeted_date'])
          .toLocal()
          .toString()
          .split(' ')[0],
      likedCount: json['liked_count'] ?? 0,
      movieUrl: json['movie_url'] ?? '',
      userId: json['user_id'] ?? '', // Null の場合は空文字
      userName: json['user_name'] ?? '', // 【修正】キーのスペルミスを修正
      userIconUrl: json['user_icon_url'] ?? '',
      gymId: json['gym_id'] ?? 0, // 【修正】nullの場合は0にする,
      gymName: json['gym_name'] ?? '',
      prefecture: json['prefecture'] ?? '',
    );

    // // MyOwnTweet型の配列
    // final tweetList = <MyOwnTweet>[];

    // MyOwnTweet korekara = MyOwnTweet();
    // // 配列の長さ(=自身のツイートの数)
    // final jsonLength = json.length;

    // // 繰返し処理で、最初から最後までのインデックスについて、
    // // 用意している配列の末尾に足していく
    // // そして、最後にreturnで返す
    // for(int i = 1; i < jsonLength; i++){
    //     tweetList.add(json[i]['tweet_id'] ?? '');
    //     tweetList.add(json[i]['tweet_contents'] ?? '');
    //     tweetList.add(json[i]['visited_date'] != null ? DateTime.parse(json[i]['visited_date']) : DateTime.now());
    //     tweetList.add(json[i]['tweeted_date']);
    //     tweetList.add(json[i]['liked_count']);
    //     tweetList.add(json[i]['movie_url']);
    //     tweetList.add(json[i]['user_id']);
    //     tweetList.add(json[i]['user_name']);
    //     tweetList.add(json[i]['user_icon_url']);
    //     tweetList.add(json[i]['gym_id']);
    //     tweetList.add(json[i]['gym_name']);
    //     tweetList.add(json[i]['prefecture']);
    // }
    // return tweetList;
  }

  // UserクラスからJSON形式への変換
  Map<String, dynamic> toJson() {
    return {
      'tweet_id': tweetId,
      'tweet_contents': tweetContents,
      'visited_date': visitedDate,
      'tweeted_date': tweetedDate,
      'liked_count': likedCount,
      'movie_url': movieUrl,
      'user_id': userId,
      'user_name': userName,
      'user_icon_url': userIconUrl,
      'gym_id': gymId,
      'gym_name': gymName,
      'prefecture': prefecture
    };
  }

  // ヘルパ関数：List<dynamic> → List<Users>に変換する
  static List<MyOwnTweets> parseUsersList(List<dynamic> jsonList) {
    return jsonList.map((json) => MyOwnTweets.fromJson(json)).toList();
  }
}
