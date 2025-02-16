import 'package:bouldering_app/view_model/gym_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GymSearchPage extends ConsumerStatefulWidget {
  const GymSearchPage({super.key});

  @override
  _GymSearchPageState createState() => _GymSearchPageState();
}

class _GymSearchPageState extends ConsumerState<GymSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> allGyms = [];

  @override
  Widget build(BuildContext context) {
    final gymsRef = ref.read(gymProvider);

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
          ],
        ));
  }
}
