import 'package:bouldering_app/model/gym_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// ■ プロバイダ
final facilityInfoProvider =
    FutureProvider.family<GymInfo, String>((ref, gymId) async {
  // HTTPリクエストURL
  final url = Uri.parse(
          'https://us-central1-gcp-compute-engine-441303.cloudfunctions.net/getData')
      .replace(queryParameters: {
    'request_id': '25',
    'gym_id': gymId.toString(),
  });

  final response = await http.get(url);

  if (response.statusCode == 200) {
    return GymInfo.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('ジム情報を取得できませんでした');
  }
});
