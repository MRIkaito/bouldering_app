import 'package:bouldering_app/view_model/gym_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ■ クラス
/// - ジム選択するページ
class GymSearchPage extends ConsumerStatefulWidget {
  const GymSearchPage({super.key});

  @override
  _GymSearchPageState createState() => _GymSearchPageState();
}

/// ■ クラス
/// - ジム選択するページ
class _GymSearchPageState extends ConsumerState<GymSearchPage> {
  final TextEditingController _controller = TextEditingController();
  // すべてのジムを格納
  List<Map<String, String>> allGyms = [];
  // フィルタリングされたジムを格納
  List<Map<String, String>> filterdGyms = [];

  // 初期化
  initState() {
    super.initState();

    // 1. すべてのジムを取得する処理
    final gymRef = ref.read(gymProvider);
    final gymsLength = gymRef.length;
    for (int i = 0; i < gymsLength; i++) {
      Map<String, String> oneGym = {
        'name': '${gymRef[i].gymName}',
        'location': '${gymRef[i].prefecture}${gymRef[i].city}'
      };
      allGyms.add(oneGym);
    }

    // 2. 初期状態では、全件のジム情報をfilterdGymsにも取得する
    filterdGyms = List.from(allGyms);
  }

  /// ■ メソッド
  /// - TextFieldに入力した文字で、allGymsのジム情報をフィルタリングして、
  /// - filterdGymsに格納するメソッド
  ///
  /// 引数
  /// - [query] TextFieldに入力された文字列
  void _filterGyms(String query) {
    setState(() {
      filterdGyms = allGyms
          .where(
              (gym) => gym["name"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// ■ ビルド
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("ジム選択", style: TextStyle(color: Colors.black)),
            backgroundColor: Color(0xFEF7FF)),
        body: Column(
          children: [
            // 検索ボックス
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'エリア・施設名・キーワード',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: _filterGyms,
                      // TODO：下記コメントアウト消去する
                      // 下記でも同様の処理が行われる
                      // onChanged: (value) => {_filterGyms(value)}
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        filterdGyms = List.from(allGyms);
                      });
                    },
                    child:
                        const Text('クリア', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),

            // ジムリスト
            Expanded(
              child: ListView.builder(
                  itemCount: filterdGyms.length,
                  itemBuilder: (context, index) {
                    final gym = filterdGyms[index];
                    return ListTile(
                        title: Text(gym['name']!),
                        subtitle: Text(gym['location']!),
                        onTap: () {
                          Navigator.pop(
                            context,
                            gym['name'], // タップされたジム名をactivity_post_page.dartに返す
                          );
                        });
                  }),
            ),
          ],
        ));
  }
}
