import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/view/components/gim_category.dart';
import 'package:bouldering_app/view/pages/searched_gim_list_page.dart';
import 'package:flutter/material.dart';

// 遷移先のページ
@RoutePage()
class SearchGimPage extends StatefulWidget {
  const SearchGimPage({Key? key}) : super(key: key);

  @override
  _SearchGimPageState createState() => _SearchGimPageState();
}

class _SearchGimPageState extends State<SearchGimPage> {
  final List<String> hokkaidoTohoku = [
    '北海道',
    '青森県',
    '岩手県',
    '宮城県',
    '秋田県',
    '山形県',
    '福島県'
  ];
  final List<String> kanto = ['茨城県', '栃木県', '群馬県', '埼玉県', '千葉県', '東京都', '神奈川県'];
  final List<String> hokurikuKoshinetsu = [
    '新潟県',
    '富山県',
    '石川県',
    '福井県',
    '山梨県',
    '長野県'
  ];
  final List<String> tokai = ['岐阜県', '静岡県', '愛知県', '三重県'];
  final List<String> kinki = ['滋賀県', '京都府', '大阪府', '兵庫県', '奈良県', '和歌山県'];
  final List<String> chugokuShikoku = [
    '鳥取県',
    '島根県',
    '岡山県',
    '広島県',
    '山口県',
    '徳島県',
    '香川県',
    '愛媛県',
    '高知県'
  ];
  final List<String> kyushuOkinawa = [
    '福岡県',
    '佐賀県',
    '長崎県',
    '熊本県',
    '大分県',
    '宮崎県',
    '鹿児島県',
    '沖縄県'
  ];

  final Map<String, bool> selectedPrefectures = {};

  @override
  void initState() {
    super.initState();
    final allPrefectures = [
      ...hokkaidoTohoku,
      ...kanto,
      ...hokurikuKoshinetsu,
      ...tokai,
      ...kinki,
      ...chugokuShikoku,
      ...kyushuOkinawa
    ];
    for (var prefecture in allPrefectures) {
      selectedPrefectures[prefecture] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 検索ボックス
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'エリア・施設名・キーワード',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // 検索ボックスのクリア
                  },
                  child:
                      const Text('クリア', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),

          // カテゴリボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryButton('ボルダリング', 0xFFFF0F00),
                _buildCategoryButton('スピード', 0xFF0056FF),
                _buildCategoryButton('リード', 0xFF00A24C),
                _buildCategoryButton('キッズ', 0xFFFFA115),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 地域選択ボタン
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRegionSection('北海道・東北', hokkaidoTohoku),
                    _buildRegionSection('関東', kanto),
                    _buildRegionSection('北陸・甲信越', hokurikuKoshinetsu),
                    _buildRegionSection('東海', tokai),
                    _buildRegionSection('近畿', kinki),
                    _buildRegionSection('中国・四国', chugokuShikoku),
                    _buildRegionSection('九州・沖縄', kyushuOkinawa),
                  ],
                ),
              ),
            ),
          ),

          // 検索ボタン
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('??? 件',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: () {
                    // 設定した条件に応じて、検索押下
                    // Navigatorで画面遷移を行う
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchedGimListPage(),
                      ),
                    );
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

  Widget _buildCategoryButton(String category, int colorCode) {
    return GestureDetector(
      onTap: () {
        setState(() {
          // カテゴリボタン押下時の処理を追加
          print("押下");
        });
      },
      child: GimCategory(
        gimCategory: category,
        colorCode: colorCode,
      ),
    );
  }

  Widget _buildRegionSection(String regionName, List<String> prefectures) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Text(
            regionName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: prefectures.map((prefecture) {
            bool isSelected = selectedPrefectures[prefecture]!;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedPrefectures[prefecture] = !isSelected;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                ),
                child: Text(
                  prefecture,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
