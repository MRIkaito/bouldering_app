import 'package:bouldering_app/model/gym_info.dart';
import 'package:bouldering_app/view/components/gim_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bouldering_app/view_model/gym_info_provider.dart';

class SearchGimPage extends ConsumerStatefulWidget {
  const SearchGimPage({super.key});

  @override
  _SearchGimPageState createState() => _SearchGimPageState();
}

class _SearchGimPageState extends ConsumerState<SearchGimPage> {
  // 選択状態を保持
  final Map<String, bool> selectedPrefectures = {};
  final Map<String, bool> selectedGymTypes = {
    "ボルダリング": false,
    "リード": false,
  };

  //ジムデータ保持
  List<GymInfo> allGyms = [];
  List<GymInfo> filterdGyms = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final gymMap = ref.read(gymInfoProvider);
    allGyms = gymMap.values.toList();
    _applyFilters(); // 初期表示
  }

  /// ■ メソッド
  /// - 選択した都道府県・ジム種別をフィルタリングして，状態保存する
  void _applyFilters() {
    final selectedPrefs = selectedPrefectures.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toSet();
    final selectedTypes = selectedGymTypes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toSet();

    setState(() {
      filterdGyms = allGyms.where((gym) {
        final matchesPref =
            selectedPrefs.isEmpty || selectedPrefs.contains(gym.prefecture);

        final matchesType = selectedTypes.isEmpty ||
            (selectedTypes.contains('ボルダリング') && gym.isBoulderingGym) ||
            (selectedTypes.contains('リード') && gym.isLeadGym);

        return matchesPref && matchesType;
      }).toList();
    });
  }

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
        backgroundColor: const Color(0xFFFEF7FF),
        surfaceTintColor: const Color(0xFFFEF7FF),
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
                    readOnly: true, // 選択のみを可能にする
                    onTap: () async {
                      await context.push("/Home/SearchGim/GymSelection");
                    },
                    decoration: InputDecoration(
                      hintText: '施設名',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // カテゴリボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildCategoryButton('ボルダリング', 0xFFFF0F00),
                const SizedBox(width: 8),
                _buildCategoryButton('リード', 0xFF00A24C),
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

          // 検索欄（件数 + 検索ボタン）
          SizedBox(
            width: double.infinity,
            height: 56,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 件数（残り幅を全て使う）
                  IntrinsicWidth(
                    child: Text(
                      '${filterdGyms.length} 件',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final gymInfoMap =
                            ref.read(gymInfoProvider); // GymInfoのMapを読む
                        final List<GymInfo> gymInfos = filterdGyms
                            .map((gym) => gymInfoMap[gym.gymId]) // GymInfoを参照
                            .whereType<GymInfo>() // null除外
                            .toList();

                        context.push(
                          "/Home/SearchGim/SearchedGimList",
                          extra: gymInfos,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '検　索',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ■ メソッド(ウィジェット)
  /// - ジムカテゴリーボタンを選択することができるボタン
  ///
  /// 引数
  /// - [category] ジムのカテゴリー('ボルダリング', 'リード')
  /// - [colorCode] ジムカテゴリーボタンのカラーコード
  ///
  /// 返り値
  /// - 指定したカテゴリー・カラーコードのジムカテゴリーボタン
  Widget _buildCategoryButton(String category, int colorCode) {
    final isSelected = selectedGymTypes[category]!;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGymTypes[category] == !isSelected;
          _applyFilters();
        });
      },
      child: GimCategory(
          gimCategory: category,
          colorCode: colorCode,
          isSelected: isSelected,
          isTappable: true,
          onTap: () {
            setState(() {
              selectedGymTypes[category] = !isSelected;
              _applyFilters();
            });
          }),
    );
  }

  /// ■ メソッド(ウィジェット)
  /// - 都道府県を選択するボタン
  ///
  /// 引数
  /// - [regionName] 次に示すそれぞれの都道府県の地域名
  ///   '北海道・東北', '関東','北陸・甲信越','東海’,'近畿','中国・四国','九州・沖縄',
  /// - [prefectures] 各地域の都道府県をリストにしたもの
  ///
  /// 返り値
  /// - 各都道府県のボタン
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
                  _applyFilters();
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
