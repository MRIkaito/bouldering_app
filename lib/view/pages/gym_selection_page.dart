import 'package:bouldering_app/view/components/gym_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GymSelectionPage extends StatelessWidget {
  const GymSelectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ジム検索', style: TextStyle(color: Colors.black)),
        elevation: 0.0,
        backgroundColor: Color(0xFEF7FF),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 検索ボックス
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'エリア・施設名・キーワード',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      // 検索フィルタ処理（必要なら追加）
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    print("クリアボタン押下");
                  },
                  child:
                      const Text('クリア', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),

          // ジムリスト表示
          GymTile(),

          // 検索ボタン
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('20 件',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () {
                    context
                        .push("/Home/SearchGim/GymSelection/SearchedGimList");
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(304, 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    '検　索',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
