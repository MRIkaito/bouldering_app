import 'package:auto_route/annotations.dart';
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
  /// - [userName] 変更後のユーザー名
  ///
  /// 戻り値
  /// - true: ユーザー名変更 成功
  /// - false: ユーザー名変更 失敗
  Future<bool> updateUserName(
      String preUserName, String setUserName, String userId) async {
    print("userI: $userId");
    print("preUserName: $preUserName");
    print("setUserName: $setUserName");

    if (userId == "") {
      return false;
    } else {
      if (preUserName == setUserName) {
        print("おなじ名前");
        return true;
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

          if (response.statusCode == 200) {
            print("成功");
            return true;
          } else {
            print("失敗");
            print("response.statusCode: ${response.statusCode}");
            return false;
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
  /// -
  ///
  /// 戻り値
  /// - true：変更成功
  /// - false：変更失敗
  Future<bool> updateFavoriteGymsOrSelfIntroduce(String preDescription,
      String updateDescription, String title, String userId) async {
    int requestId;

    if (userId == "") {
      return false;
    } else {
      if (preDescription == updateDescription) {
        return true;
      } else {
        if (title == "自己紹介") {
          requestId = 15;
        } else {
          requestId = 16;
        }

        final url = Uri.parse(
                'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
            .replace(queryParameters: {
          'request_id': requestId.toString(),
          'user_id': userId.toString(),
        });

        try {
          final response = await http.get(url);

          if (response.statusCode == 200) {
            return true;
          } else {
            return false;
          }
        } catch (error) {
          throw Exception("更新に失敗しました: ${error}");
        }
      }
    }
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
