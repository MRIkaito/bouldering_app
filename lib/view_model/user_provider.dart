import 'package:bouldering_app/model/boulder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - ログイン時に取得するユーザー情報を管理する
/// - Usersの状態をクラスとして保持する
class UserNotifier extends StateNotifier<Boulder?> {
  /// ■コンストラクタ
  /// - 状態をnullに初期化して、未ログイン状態にする
  UserNotifier() : super(null);

  /// ■ メソッド：fetchUserData
  /// - ユーザーデータを取得する
  ///
  /// 引数：
  /// - [userId] ユーザーのID
  Future<void> fetchUserData(String userId) async {
    int requestId = 3;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId,
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // レスポンスボディをJSONとしてデコードする
        // ここでまず、[{"id":1. "name":"Alice"}]のような形で取得する
        final List<dynamic> userList = jsonDecode(response.body);

        if (userList.isEmpty) {
          throw Exception("ユーザーデータが空です");
        }

        // ここで、{"id":1. "name":"Alice"}を取得
        // ※ データは1つしか取得しないので、[0]でアクセスしてもOK
        final Map<String, dynamic> userMap = userList[0];

        // fromJsonで、Boulderクラスのデータをすべて取得する
        final userState = Boulder.fromJson(userMap);
        print("[目的部分]userState確認: $userState");

        // 最後に、state(状態)としてデータを取得する
        state = userState;
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (error) {
      throw Exception("ログインに失敗しました: ${error}");
    }
  }

  /// ■ メソッド：insertNewUserData
  /// - (サインアップ)ユーザー情報を新規登録する
  /// - サインアップ時に使用する
  ///
  /// 引数：
  /// - [userId] ユーザーID.
  /// - [email] メールアドレス
  ///
  /// 返り値：
  /// - true：新規登録成功
  /// - false：新規登録失敗
  Future<bool> insertNewUserData(String userId, String email) async {
    int requestId = 11;

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': requestId.toString(),
      'user_id': userId.toString(),
      'email': email.toString(),
    });

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// ■ メソッド：updateUserName
  /// - ユーザー名を変更する
  /// - userIdを取得できていないと、変更失敗(false)
  /// - 変更前・後の名前が同じ場合は、DBアクセスなしで終了(true)
  ///
  /// 引数
  /// - [preUserName] 変更前のユーザー名
  /// - [setUserName] 変更後のユーザー名
  /// - [userId] ログインしているユーザーのユーザーID
  ///
  /// 戻り値
  /// - true: ユーザー名変更 成功
  /// - false: ユーザー名変更 失敗
  Future<bool> updateUserName(
      String preUserName, String setUserName, String userId) async {
    print("userId: $userId");
    print("preUserName: $preUserName");
    print("setUserName: $setUserName");

    if (userId == "") {
      return false;
    } else {
      if (preUserName == setUserName) {
        return true; // 名前の変更完了(※同じ名前のケース)
      } else {
        int requestId = 14;

        final url = Uri.parse(
                'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
            .replace(queryParameters: {
          'request_id': requestId.toString(),
          'user_id': userId.toString(),
          'user_name': setUserName,
        });

        try {
          final response = await http.get(url);

          if ((response.statusCode == 200) && (state != null)) {
            state = state!.copyWith(userName: setUserName); // ユーザー名を状態更新
            return true; // 名前の変更完了
          } else {
            print("失敗");
            print("response.statusCode: ${response.statusCode}");
            return false; // 名前の変更失敗
          }
        } catch (error) {
          throw Exception("ユーザー名変更に失敗しました: ${error}");
        }
      }
    }
  }

  /// ■ メソッド：updateFavoriteGymsOrSelfIntroduce
  /// - 自己紹介文、または好きなジム欄を更新する
  /// - 更新前と、更新後の文章が同じ場合は、DBアクセスせずに終了(true)
  /// - userIdを取得できていないと、変更失敗とする(false)
  ///
  /// 引数
  /// - [preDescripiton] 編集前の紹介文、または好きなジム
  /// - [updateDescription] 編集後の紹介文、または好きなジム
  /// - [title] 「自己紹介」「好きなジム」のいずれか
  /// - [userId] ログインしているユーザーのID
  ///
  /// 戻り値
  /// - true：変更成功
  /// - false：変更失敗
  Future<bool> updateFavoriteGymsOrUserIntroduce(String preDescription,
      String updateDescription, String title, String userId) async {
    int requestId = 15;
    bool type;

    /* デバック */
    print("preDescription: $preDescription");
    print("updateDescription: $updateDescription");
    print("title: $title");
    print("userId: $userId");

    // titleによって，typeの値を変更
    if (title == "自己紹介") {
      type = true; // 自己紹介
    } else {
      type = false; // 好きなジム
    }

    if (userId == "") {
      return false; // userIdがない場合は変更失敗(false)
    } else {
      if (preDescription == updateDescription) {
        return true; // 変更前・変更後の値が同じなら，DBアクセス無しでtrue
      } else {
        final url = Uri.parse(
                'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
            .replace(queryParameters: {
          'request_id': requestId.toString(),
          'description': updateDescription.toString(),
          'user_id': userId.toString(),
          'type': type.toString()
        });

        try {
          final response = await http.get(url);

          // 自己紹介・又は好きなジムを状態変更
          if ((response.statusCode == 200) &&
              (state != null) &&
              (title == "自己紹介")) {
            state = state!.copyWith(userIntroduce: updateDescription);
            return true; // 紹介文の更新成功
          } else if ((response.statusCode == 200) &&
              (state != null) &&
              (title == "好きなジム")) {
            state = state!.copyWith(favoriteGym: updateDescription);
            return true; // 好きなジムの更新成功
          } else {
            print("失敗");
            print("response.statusCode: ${response.statusCode}");
            return false; // 紹介文、または好きなジムの更新失敗
          }
        } catch (error) {
          throw Exception("更新に失敗しました: ${error}");
        }
      }
    }
  }

  /// ■ メソッド：updateBoulStartDate
  /// - ボルダリングを開始した日程を更新する
  /// - 更新前と更新後の日程が同じ場合は、DBアクセスせずに終了(true)
  /// - userIdを取得できていないと、更新失敗とする(false)
  ///
  /// 引数
  /// - [preYear] 更新前の開始年
  /// - [preMonth] 更新前の開始月
  /// - [preDay]更新前の開始日
  /// - [updateYear] 更新後の開始年
  /// - [updateMonth] 更新後の開始月
  /// - [updateDay] 更新後の日
  /// - [userId] ログインしているユーザーのID
  ///
  /// 戻り値
  /// - true：更新成功
  /// - false：更新失敗
  Future<bool> updateBoulStartDate(int preYear, int preMonth, int preDay,
      int updateYear, int updateMonth, int updateDay, String userId) async {
    int requestId = 16;

    // ユーザーIDなし
    if (userId.isEmpty) {
      return false;
    }

    if ((preYear == updateYear) &&
        (preMonth == updateMonth) &&
        (preDay == updateDay)) {
      return true; // 更新前・更新後が同じ場合は、DBアクセス無し
    } else {
      // 年月日を”YYYY-MM-DD"のフォーマット
      final formattedBoulStartDate =
          _formatDate(updateYear, updateMonth, updateDay);

      final url = Uri.parse(
              'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
          .replace(queryParameters: {
        'request_id': requestId.toString(),
        'user_id': userId.toString(),
        'boul_start_date': formattedBoulStartDate.toString(),
      });
      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          // ボル活開始日を更新
          if ((state != null)) {
            state = state!.copyWith(
                boulStartDate: DateTime(updateYear, updateMonth, updateDay));
          }
          return true; // 紹介文、または好きなジムの変更成功
        } else {
          print("失敗");
          print("response.statusCode: ${response.statusCode}");
          return false; // 紹介文、または好きなジムの変更失敗
        }
      } catch (error) {
        throw Exception("更新に失敗しました：${error}");
      }
    }
  }

  /// ■ メソッド
  /// - 日付をフォーマットする
  ///
  /// 引数
  /// - [year]: 年
  /// - [month] ：月
  /// - [day] : 日
  ///
  /// 返り値
  /// - YYYY-MM-DDにフォーマットした日付
  String _formatDate(int year, int month, int day) {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  /// ■ メソッド：clearUserData
  /// - ユーザ─情報をクリアする(state = null)
  /// - ログアウト時に使用する
  void clearUserData() {
    state = null;
  }
}

/// ■ プロバイダ
final userProvider = StateNotifierProvider<UserNotifier, Boulder?>((ref) {
  return UserNotifier();
});

/// ■ プロバイダ
/// - 非同期表示用のプロバイダ
final asyncUserProvider = FutureProvider<Boulder?>((ref) async {
  await Future.delayed(const Duration(seconds: 2));
  final userNotifier = ref.read(userProvider.notifier);
  final userState = ref.watch(userProvider);
  final userId = FirebaseAuth.instance.currentUser?.uid;

  print("userNotifier: ${userNotifier}");
  print("user: ${userState}");
  print("userId: ${userId}");

  // user(状態)を取得できておらず，またuserIdは取得できているときに
  // 改めてuser(状態)を取得する
  if ((userState == null) && (userId != null)) {
    userNotifier.fetchUserData(userId);
  }

  return ref.watch(userProvider);
});
