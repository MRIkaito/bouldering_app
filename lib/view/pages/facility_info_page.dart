import 'package:bouldering_app/view/components/gim_category.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FacilityInfoPage extends StatelessWidget {
  const FacilityInfoPage({Key? key}) : super(key: key);

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: [
            // SwitcherTabの下に中身のスクロール部分を配置
            Positioned(
              top: 0, // SwitcherTabのheight分を調整
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: const SwitcherTab(
                    leftTabName: "施設情報",
                    rightTabName: "ボル活",
                    colorCode: 0xFFFFFFFF),
              ),
            ),

            // コンテンツ部分
            Padding(
              padding: const EdgeInsets.only(
                  top: kToolbarHeight), // AppBarとSwitherTabの高さを加味した値
              child: TabBarView(children: [
                SingleChildScrollView(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 80), // 下部に余白を追加
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // タイトルとタグ
                      const Text(
                        'Folkボルダリングジム',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),

                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GimCategory(
                            gimCategory: 'ボルダリング',
                            colorCode: 0xFFF44336,
                          ),
                          SizedBox(height: 8),
                          GymIkitaiBoullogCount(
                              ikitaiCount: '200', boullogCount: '400'),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ギャラリー
                      SizedBox(
                        height: 100, // ギャラリーの高さ
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal, // 横スクロール
                          itemCount: 5, // 画像の枚数←外部DBから取得した枚数にする
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildImage(
                                  'lib/view/assets/gym_facilitation.png'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 基本情報
                      const Text(
                        '基本情報',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      _buildInfoRow('住所', '神奈川県横浜市港北新羽町５７６－１'),
                      _buildInfoRow('TEL', 'ー'),
                      _buildInfoRow(
                        'HP',
                        'https://folkboulderinggym.com/',
                        isLink: true,
                        onTap: () =>
                            _launchUrl('https://folkboulderinggym.com/'),
                      ),
                      _buildInfoRow('定休日', 'なし'),
                      _buildInfoRow(
                        '営業時間',
                        '月曜日 14:00〜22:30\n火曜日 14:00〜22:30\n水曜日 14:00〜22:30\n木曜日 18:00〜22:30\n金曜日 14:00〜22:30\n土曜日 10:00〜20:00\n日曜日 10:00〜20:00',
                      ),
                      const SizedBox(height: 16),

                      // 支払い方法
                      _buildSectionTitle('支払い方法'),
                      const Text('◯ 現金\n◯ クレジットカード\n◯ 電子マネー（Paypay）'),

                      const SizedBox(height: 16),

                      // 料金情報
                      _buildSectionTitle('料金'),
                      const Text(
                        '20歳以上 会員登録：1,500円\n20歳以上2時間：1,700円\n20歳以上1日利用：1,900円\n\n'
                        '中学生〜19歳会員登録：1,500円\n中学生〜19歳2時間：1,500円\n中学生〜19歳1日：1,700円\n\n'
                        '4歳から小学生会員登録：1,500円\n4歳から小学生2時間：1,000円\n4歳から小学生1日：1,500円\n\n'
                        'その他\n4歳から小学生1時間体験利用：1,200円\n※4歳から小学生限定プラン\n※レンタルシューズ代込み\n\n'
                        'OYAKO体験利用：2,500円/1時間\n※大人1名+子ども1名\n※大人追加+1,300円/1時間\n※利用時間の延長はできません\n\n'
                        'キッズスクール：12,000円(30DAYS)\n※小学生のみ\n※毎週、月・水・金 17:00〜18:00のクライミングスクール\n'
                        '30DAYS PASS付き\n※人数上限があるため、気になる方はお問い合わせください。\n\n'
                        '30DAYS PASS\n一般：14,000円\n※7日以内の更新で、更新ごとに1,000円OFF。割引額最大12,000円\n'
                        '中学生〜19歳：12,000円\n4歳〜小学生：10,000円\n\n'
                        'PUNCH TICKET\n購入日から半年間有効の10回利用回数券。シェアOK\n一般：17,000円\n中学生〜19歳：15,000円\n\n'
                        'レンタル\nシューズ：400円\n※靴下の着用が必要となります\nチョーク：200円\n\n'
                        'その他\n会員カード再発行：500円\n',
                      ),
                      const SizedBox(height: 16),

                      // 設備情報
                      _buildSectionTitle('設備'),
                      const Text('◯ 駐車場（1台）'),
                    ],
                  ),
                ),
                Text("Test")
              ]),
            ),

            // 下部固定のボタン
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // イキタイボタンの処理
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        side: const BorderSide(color: Colors.blue),
                      ),
                      child: const Text('イキタイ',
                          style: TextStyle(
                            color: Colors.blue,
                          )),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // ボル活投稿ボタンの処理
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('ボル活投稿',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 各種ウィジェットビルドメソッド
  Widget _buildTab(String title, bool isSelected) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
        if (isSelected)
          const Divider(
            thickness: 2,
            color: Colors.blue,
          ),
      ],
    );
  }

  Widget _buildTag(String text, {Color color = Colors.grey}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCounter(String label, String count) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(count,
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildImage(String imagePath) {
    return Container(
      width: 150,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isLink = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: isLink ? onTap : null,
              child: Text(
                value,
                style: TextStyle(color: isLink ? Colors.blue : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class GymIkitaiBoullogCount extends StatelessWidget {
  final String ikitaiCount;
  final String boullogCount;

  const GymIkitaiBoullogCount({
    Key? key,
    required this.ikitaiCount,
    required this.boullogCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // イキタイ部分
          Text(
            'イキタイ ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            ikitaiCount,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          // 区切り線
          Container(
            width: 1,
            height: 16,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          // ボル活部分
          Text(
            'ボル活 ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            boullogCount,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
