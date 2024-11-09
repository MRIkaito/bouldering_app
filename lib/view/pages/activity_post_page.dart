import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用のパッケージ

@RoutePage()
class ActivityPostPage extends StatefulWidget {
  @override
  _ActivityPostPageState createState() => _ActivityPostPageState();
}

class _ActivityPostPageState extends State<ActivityPostPage> {
  final TextEditingController _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int _currentTextLength = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      setState(() {
        _currentTextLength = _textController.text.length;
      });
    });
  }

  // 日付選択のメソッド
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ボル活投稿'),
        actions: [
          TextButton(
            onPressed: () {
              // 投稿処理
              print("投稿するボタンが押されました");
            },
            child: const Text(
              '投稿する',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ジム名
            const Text(
              'フォークボルダリングジム',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 日付選択ボタン
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey[600]),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('yyyy.MM.dd').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // テキスト入力フィールド
            TextField(
              controller: _textController,
              maxLength: 400,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '今日登ったレベル，時間など好きなことを書きましょう。',
                border: InputBorder.none,
              ),
            ),

            // カウンターと写真追加ボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 写真追加ボタン
                GestureDetector(
                  onTap: () {
                    print("写真を追加");
                  },
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.image, size: 30, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          '写真を追加',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
