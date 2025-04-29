import 'package:bouldering_app/model/boulder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 他のユーザーのデータを取得するプロバイダ
final otherUserProvider =
    FutureProvider.autoDispose.family<Boulder?, String>((ref, userId) async {
  // 取得先URL
  final url = Uri.parse(
          'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
      .replace(queryParameters: {
    'request_id': '3',
    'user_id': userId,
  });

  try {
    // データ取得
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> userList = jsonDecode(response.body);

      if (userList.isEmpty) {
        throw Exception("ユーザーデータが空です");
      }

      final Map<String, dynamic> userMap = userList[0];
      final otherUser = Boulder.fromJson(userMap);
      return otherUser;
    } else {
      throw Exception("データ取得に失敗しました");
    }
  } catch (error) {
    throw Exception("ユーザーデータ取得に失敗しました: ${error}");
  }
});
