import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';
import 'package:flutter/material.dart';
import 'package:bouldering_app/view/components/gim_card.dart';

class SearchedGimListPage extends StatelessWidget {
  const SearchedGimListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
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
                ],
              ),
            ),

            // タブバー
            const SwitcherTab(leftTabName: "施　設", rightTabName: "ボル活"),

            // タブビュー内でのリスト
            Expanded(
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // チューニングアイコンと検索条件
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.tune),
                                onPressed: () {},
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, bottom: 8),
                                child: const Text("神奈川県のジム施設"),
                              ),
                              Container(
                                height: 36,
                                padding:
                                    const EdgeInsets.only(left: 16, right: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFFEEEEEE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "300件",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          "↑↓",
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: const Text(
                                            "イキタイ多い順",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ジムリスト
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 3, // ダミーデータとして3つのジムを表示
                          itemBuilder: (context, index) {
                            return const GimCard(
                              gymName: 'Folkボルダリングジム',
                              gymPrefecture: '神奈川県',
                              ikitaiCount: 200,
                              boulCount: 400,
                              minimumFee: 1500,
                              isBoulderingGym: true,
                              isLeadGym: false,
                              isSpeedGym: false,
                              isOpened: true,
                              gymPhotos: [],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // 2つ目のタブの内容
                  // 検索条件に関連するジムのボル活を表示する
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // チューニングアイコンと検索条件
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.tune),
                                onPressed: () {},
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, bottom: 8),
                                child: const Text("神奈川県のジム施設"),
                              ),
                            ],
                          ),
                        ),

                        // ジムリスト
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return BoulLog(
                              userName: 'test',
                              visitedDate: '2020-09-23',
                              gymName: 'Dボルダリング',
                              prefecture: '神奈川県',
                              tweetContents: '今はテスト用',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
