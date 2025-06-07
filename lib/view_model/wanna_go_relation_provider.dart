import 'package:bouldering_app/model/gym_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ クラス
/// - イキタイ登録したジムを管理するクラス
///
/// 状態： {ジムID：ジム情報}
class WannaGoRelationNotifier extends StateNotifier<Map<int, GymInfo>> {
  /// ■ コンストラクタ
  WannaGoRelationNotifier() : super({});

  /// ■ プロパティ
  bool _isGymCardLoading = false;

  /// ■ ゲッター
  bool get isGymCardLoadfing => _isGymCardLoading;

  /// ■ メソッド
  /// - 自分が保持しているイキタイジムをすべて破棄する
  ///
  /// 備考
  /// - リフレッシュ時に保持しているイキタイジム情報をすべて破棄する処理として実装
  /// - fetchWannaGoGymCardsに状態通知の処理が実装されているため、問う処理では
  /// 状態通知(= copyWith)は不要
  void disposeWannaGoGymCards() {
    state = {};
  }

  /// ■ メソッド
  /// - 自分がイキタイ登録しているジムをすべて取得する関数
  ///
  /// 引数
  /// -[userId] ユーザーID
  ///
  /// 返り値
  /// なし
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

        final List<GymInfo> registeredGymCards = jsonData
            .map((gymCard) => GymInfo(
                  gymId: gymCard['gym_id'] is int
                      ? gymCard['gym_id']
                      : int.tryParse(gymCard['gym_id'].toString()) ?? 0,
                  gymName: gymCard['gym_name'] ?? '',
                  hpLink: gymCard['hp_link'] ?? '',
                  prefecture: gymCard['prefecture'] ?? '',
                  city: gymCard['city'] ?? '',
                  addressLine: gymCard['address_line'] ?? '',
                  latitude: gymCard['latitude'] is double
                      ? gymCard['latitude']
                      : double.tryParse(gymCard['latitude'].toString()) ?? 0.0,
                  longitude: gymCard['longitude'] is double
                      ? gymCard['longitude']
                      : double.tryParse(gymCard['longitude'].toString()) ?? 0.0,
                  telNo: gymCard['tel_no'] ?? '',
                  fee: gymCard['fee'] ?? '',
                  minimumFee: gymCard['minimum_fee'] is int
                      ? gymCard['minimum_fee']
                      : int.tryParse(gymCard['minimum_fee'].toString()) ?? 0,
                  equipmentRentalFee: gymCard['equipment_rental_fee'] ?? '',
                  ikitaiCount: gymCard['ikitai_count'] is int
                      ? gymCard['ikitai_count']
                      : int.tryParse(gymCard['ikitai_count'].toString()) ?? 0,
                  boulCount: gymCard['boul_count'] is int
                      ? gymCard['boul_count']
                      : int.tryParse(gymCard['boul_count'].toString()) ?? 0,
                  isBoulderingGym:
                      gymCard['is_bouldering_gym'].toString().toLowerCase() ==
                          'true',
                  isLeadGym:
                      gymCard['is_lead_gym'].toString().toLowerCase() == 'true',
                  isSpeedGym:
                      gymCard['is_speed_gym'].toString().toLowerCase() ==
                          'true',
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

        // ✅ copyWith() を利用して state を更新する
        state = Map.from(state)
          ..addAll({
            for (var registeredGymCard in registeredGymCards)
              registeredGymCard.gymId: registeredGymCard.copyWith()
          });

        print("🟢 [DEBUG] 更新後の gymCards: ${state}");
        print("🟢 [DEBUG] gymCards.keys: ${state.keys}");
        print("🟢 [DEBUG] gymCards.values.toList(): ${state.values.toList()}");
      } else {
        print(
            "[ERROR] Failed to fetch gym cards. Status: ${response.statusCode}");
        print("[ERROR] Response body: ${response.body}");
      }
    } catch (error) {
      print("❌ [ERROR] Exception in fetchWannaGoGymCards(): $error");
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
        _updateGymCards(gymId);
      } else {
        throw Exception("イキタイジム登録に失敗しました");
      }
    } catch (error) {
      print("エラーメッセージ:${error}");
    }
  }

  /// ■ メソッド
  /// - イキタイ登録したジムの情報を取得し、そのジムを状態に追加する
  ///
  /// 引数
  /// - [gymId] ジムのID
  ///
  /// 返り値
  /// なし
  Future<void> _updateGymCards(String gymId) async {
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '25',
      'gym_id': gymId.toString(),
    });

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        /// Map<String, dynamic> もしくは List<Map<String, dynamic>> 両方に対応
        final decoded = jsonDecode(response.body);

        final List<Map<String, dynamic>> gymCards = decoded is List
            ? List<Map<String, dynamic>>.from(decoded)
            : [Map<String, dynamic>.from(decoded)];

        for (final gymCard in gymCards) {
          final GymInfo newRegisteredGym = GymInfo(
            gymId: gymCard['gym_id'] is int
                ? gymCard['gym_id']
                : int.tryParse(gymCard['gym_id'].toString()) ?? 0,
            gymName: gymCard['gym_name'] ?? '',
            hpLink: gymCard['hp_link'] ?? '',
            prefecture: gymCard['prefecture'] ?? '',
            city: gymCard['city'] ?? '',
            addressLine: gymCard['address_line'] ?? '',
            latitude: double.tryParse(gymCard['latitude'].toString()) ?? 0.0,
            longitude: double.tryParse(gymCard['longitude'].toString()) ?? 0.0,
            telNo: gymCard['tel_no'] ?? '',
            fee: gymCard['fee'] ?? '',
            minimumFee: gymCard['minimum_fee'] is int
                ? gymCard['minimum_fee']
                : int.tryParse(gymCard['minimum_fee'].toString()) ?? 0,
            equipmentRentalFee: gymCard['equipment_rental_fee'] ?? '',
            ikitaiCount: gymCard['ikitai_count'] is int
                ? gymCard['ikitai_count']
                : int.tryParse(gymCard['ikitai_count'].toString()) ?? 0,
            boulCount: gymCard['boul_count'] is int
                ? gymCard['boul_count']
                : int.tryParse(gymCard['boul_count'].toString()) ?? 0,
            isBoulderingGym:
                gymCard['is_bouldering_gym'].toString().toLowerCase() == 'true',
            isLeadGym:
                gymCard['is_lead_gym'].toString().toLowerCase() == 'true',
            isSpeedGym:
                gymCard['is_speed_gym'].toString().toLowerCase() == 'true',
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
          );

          state = {
            ...state,
            newRegisteredGym.gymId: newRegisteredGym,
          };
        }
      } else {
        throw Exception("イキタイジム登録に失敗しました");
      }
    } catch (error) {
      print("エラーメッセージ:$error");
    }
  }

  /// ■ メソッド
  /// - イキタイ登録を解除(削除)する
  ///
  /// 引数
  /// - [user_id] (イキタイ登録した)ユーザーのID
  /// - [gym_id] (イキタイ登録を解除された)ジムのID
  ///
  /// 返り値
  /// - なし
  Future<void> deleteWannaGoGym(String userId, String gymId) async {
    final url = Uri.parse(
            'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
        .replace(queryParameters: {
      'request_id': '27',
      'user_id': userId.toString(),
      'gym_id': gymId.toString(),
    });

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("削除成功：${response.body}");
        // UI更新処理があれば実装する
      }
    } catch (error) {
      print("エラー発生：$error");
    }
  }
}

/// ■ プロバイダ
/// イキタイ登録したジム(状態)を提供するプロバイダ
final wannaGoRelationProvider =
    StateNotifierProvider<WannaGoRelationNotifier, Map<int, GymInfo>>((ref) {
  return WannaGoRelationNotifier();
});
