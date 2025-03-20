import 'package:bouldering_app/model/gym_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - (後々外部登録する予定)
/// イキタイジムリレーションのデータ状態を表したデータ構造クラス

// 現在 未使用
// class WannaGoRelation {
//   final String userId;
//   final int gymId;
//   final DateTime createdAt;

//   WannaGoRelation({
//     required this.userId,
//     required this.gymId,
//     required this.createdAt,
//   });
// }

/// ■ クラス
/// - イキタイ登録したジムを管理するクラス
class WannaGoRelationNotifier extends StateNotifier<List<GymInfo>> {
  /// ■ コンストラクタ
  WannaGoRelationNotifier() : super([]);

  /// ■ プロパティ
  bool _isGymCardLoading = false;

  /// ■ ゲッター
  bool get isGymCardLoadfing => _isGymCardLoading;

  /// ■ メソッド
  /// 自身のイキタイ登録したジムを取得する関数
  ///
  /// 引数
  ///
  ///
  /// 返り値
  Future<void> fetchWannaGoGymCards(String userId) async {
    // すでにローディング中のときは実行しない
    if (_isGymCardLoading) return;

    // イキタイ登録ジム 取得開始
    _isGymCardLoading = true;
    print(
        "🟢 [DEBUG] fetchWannaGoGymCards() called. isGymCardLoading: $_isGymCardLoading");

    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '23',
      'user_id': userId,
    });
    print("[DEBUG] Fetching gym cards from: $url");

    try {
      final response = await http.get(url);
      print("[DEBUG] Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        print("[DEBUG] Gym cards fetched: $jsonData");

        final List<GymInfo> newGymCards = jsonData
            .map((gymCard) => GymInfo(
                  gymId: int.tryParse(gymCard['gym_id']) ?? 0,
                  gymName: gymCard['gym_name'] ?? '',
                  hpLink: gymCard['hp_link'] ?? '',
                  prefecture: gymCard['prefecture'] ?? '',
                  city: gymCard['city'] ?? '',
                  addressLine: gymCard['address_line'] ?? '',
                  latitude:
                      double.tryParse(gymCard['latitude'].toString()) ?? 0.0,
                  longitude:
                      double.tryParse(gymCard['longitude'].toString()) ?? 0.0,
                  telNo: gymCard['tel_no'] ?? '',
                  fee: gymCard['fee'] ?? '',
                  minimumFee: int.tryParse(gymCard['minimum_fee']) ?? 0,
                  equipmentRentalFee: gymCard['equipment_rental_fee'] ?? '',
                  ikitaiCount: int.tryParse(gymCard['ikitai_count']) ?? 0,
                  boulCount: int.tryParse(gymCard['boul_count']) ?? 0,
                  isBoulderingGym: gymCard['is_bouldering_gym'] == 'true',
                  isLeadGym: gymCard['is_lead_gym'] == 'true',
                  isSpeedGym: gymCard['is_speed_gym'] == 'true',
                  sunOpen: gymCard['sun_open'] ?? '-',
                  sunClose: gymCard['sun_close'] ?? '-',
                  monOpen: gymCard['mon_open'] ?? '-',
                  monClose: gymCard['mon_close'] ?? '-',
                  tueOpen: gymCard['tue_open'] ?? '-',
                  tueClose: gymCard['tue_close'] ?? '-',
                  wedOpen: gymCard['wed_open'] ?? '-',
                  wedClose: gymCard['wed_close'] ?? '-',
                  thuOpen: gymCard['thu_open'] ?? '-',
                  thuClose: gymCard['thu_close'] ?? '-',
                  friOpen: gymCard['fri_open'] ?? '-',
                  friClose: gymCard['fri_close'] ?? '-',
                  satOpen: gymCard['sat_open'] ?? '-',
                  satClose: gymCard['sat_close'] ?? '-',
                ))
            .toList();

        // イキタイジム情報を保持
        state = [...state, ...newGymCards];
        print("[DEBUG] Gym cards fetched. Total count: ${state.length}");
      } else {
        print(
            "[ERROR] Failed to fetch gym cards. Status: ${response.statusCode}");
        print("[ERROR] Response body: ${response.body}");
      }
    } catch (error) {
      //
    } finally {
      _isGymCardLoading = false;
    }
  }

  /// ■ メソッド
  /// - ユーザーID, ジムIDをもらって、イキタイ登録したユーザーをDBに登録する処理
  ///
  /// 引数
  /// - [userId] (イキタイ登録した)ユーザーID
  /// - [gymId] (イキタイ登録を押された)ジムのジムID
  ///
  /// 返り値
  /// - 無し
  /// ※ イキタイジムリレーションに登録して状態を変更する
  Future<void> registerWannaGoGym(String userId, String gymId) async {
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '26',
      'user_id': userId.toString(),
      'gym_id': gymId.toString(),
    });

    try {
      // ここでAPIリクエストを投げて「イキタイ」登録 or 解除
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // イキタイ登録したジムのジムIDを渡し，状態を更新する処理を呼び出す
        fetchSpecificGymCard(gymId);
      } else {
        throw Exception("イキタイジム登録に失敗しました");
      }
    } catch (error) {
      print("エラーメッセージ:${error}");
    }
  }

  /// ■ メソッド
  /// - イキタイ登録したジム情報を取得して状態に追加する
  ///
  /// 引数
  /// - [gymId]ジムのID
  ///
  /// 返り値
  /// なし
  Future<void> fetchSpecificGymCard(String gymId) async {
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '27',
      'gym_id': gymId.toString(),
    });

    try {
      // ここでAPIリクエストを投げて「イキタイ」登録 or 解除
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> wannaGoRelationList = jsonDecode(response.body);
        final List<GymInfo> newWannaGoRelationList = wannaGoRelationList
            .map((gymCard) => GymInfo(
                  gymId: int.tryParse(gymCard['gym_id']) ?? 0,
                  gymName: gymCard['gym_name'] ?? '',
                  hpLink: gymCard['hp_link'] ?? '',
                  prefecture: gymCard['prefecture'] ?? '',
                  city: gymCard['city'] ?? '',
                  addressLine: gymCard['address_line'] ?? '',
                  latitude:
                      double.tryParse(gymCard['latitude'].toString()) ?? 0.0,
                  longitude:
                      double.tryParse(gymCard['longitude'].toString()) ?? 0.0,
                  telNo: gymCard['tel_no'] ?? '',
                  fee: gymCard['fee'] ?? '',
                  minimumFee: int.tryParse(gymCard['minimum_fee']) ?? 0,
                  equipmentRentalFee: gymCard['equipment_rental_fee'] ?? '',
                  ikitaiCount: int.tryParse(gymCard['ikitai_count']) ?? 0,
                  boulCount: int.tryParse(gymCard['boul_count']) ?? 0,
                  isBoulderingGym: gymCard['is_bouldering_gym'] == 'true',
                  isLeadGym: gymCard['is_lead_gym'] == 'true',
                  isSpeedGym: gymCard['is_speed_gym'] == 'true',
                  sunOpen: gymCard['sun_open'] ?? '-',
                  sunClose: gymCard['sun_close'] ?? '-',
                  monOpen: gymCard['mon_open'] ?? '-',
                  monClose: gymCard['mon_close'] ?? '-',
                  tueOpen: gymCard['tue_open'] ?? '-',
                  tueClose: gymCard['tue_close'] ?? '-',
                  wedOpen: gymCard['wed_open'] ?? '-',
                  wedClose: gymCard['wed_close'] ?? '-',
                  thuOpen: gymCard['thu_open'] ?? '-',
                  thuClose: gymCard['thu_close'] ?? '-',
                  friOpen: gymCard['fri_open'] ?? '-',
                  friClose: gymCard['fri_close'] ?? '-',
                  satOpen: gymCard['sat_open'] ?? '-',
                  satClose: gymCard['sat_close'] ?? '-',
                ))
            .toList();

        // 状態更新：イキタイ登録したジム情報を更新
        state = [...newWannaGoRelationList, ...state];
      } else {
        throw Exception("イキタイジム登録に失敗しました");
      }
    } catch (error) {
      print("エラーメッセージ:${error}");
    }
  }

  /// ■ メソッド
  /// - イキタイ登録を解除する
  ///
  /// 引数
  /// - [user_id] (イキタイ登録した)ユーザーのID
  /// - [gym_id] (イキタイ登録を解除された)ジムのID
  ///
  /// 返り値
  /// - なし
  Future<void> deleteWannaGoGym(String userId, int gymId) async {
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '27',
      'user_id': userId.toString(),
      'gym_id': gymId.toString(),
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {}
    } catch (error) {}
  }
}

/// ■ プロバイダ
/// イキタイ登録したジム(状態)を提供するプロバイダ
final wannaGoRelationProvider =
    StateNotifierProvider<WannaGoRelationNotifier, List<GymInfo>>((ref) {
  return WannaGoRelationNotifier();
});
