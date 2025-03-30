import 'package:bouldering_app/view/components/gim_category.dart';
import 'package:flutter/material.dart';

class GimCard extends StatelessWidget {
  final String gymName;
  final String gymPrefecture;
  final int ikitaiCount;
  final int boulCount;
  final int minimumFee;
  final bool isBoulderingGym;
  final bool isLeadGym;
  final bool isSpeedGym;
  final bool isOpened;
  final List<String>? gymPhotos;

  const GimCard({
    super.key,
    required this.gymName,
    required this.gymPrefecture,
    required this.ikitaiCount,
    required this.boulCount,
    required this.minimumFee,
    required this.isBoulderingGym,
    required this.isLeadGym,
    required this.isSpeedGym,
    required this.isOpened,
    this.gymPhotos,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ジム名と所在地を同じ行に配置
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: gymName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const TextSpan(text: ' '), // スペースを追加
                TextSpan(
                  text: '[$gymPrefecture]',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ジムカテゴリ
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              if (isBoulderingGym)
                const GimCategory(gimCategory: 'ボルダリング', colorCode: 0xFFF44336),
              if (isLeadGym)
                const GimCategory(gimCategory: 'リード', colorCode: 0xFFFF0F00),
              if (isSpeedGym)
                const GimCategory(gimCategory: 'スピード', colorCode: 0xFFFF0F00),
            ],
          ),
          const SizedBox(height: 8),

          // ジム写真
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: (gymPhotos != null && gymPhotos!.isNotEmpty)
                  ? gymPhotos!
                      .map((photoUrl) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                photoUrl,
                                width: 132,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    width: 132,
                                    height: 100,
                                    child: Center(
                                        child: CircularProgressIndicator()),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint(
                                      "❌ [GimCard] Image load failed. URL: $photoUrl");
                                  return Container(
                                    width: 132,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '写真なし',
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 14),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ))
                      .toList()
                  : [
                      Container(
                        width: 132,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '写真なし',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 14),
                          ),
                        ),
                      )
                    ],
            ),
          ),
          const SizedBox(height: 8),

          // ジム利用情報
          Row(
            children: [
              const Icon(Icons.currency_yen, size: 18),
              const SizedBox(width: 4),
              Text('${minimumFee.toString()}〜'),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 4),
              isOpened ? const Text('OPEN') : const Text("CLOSE"),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // イキタイカウント数
              const Text(
                'イキタイ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$ikitaiCount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  height: 1.25,
                ),
              ),
              const SizedBox(width: 16),

              // ボル活ツイート数
              const Text(
                'ボル活',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$boulCount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  height: 1.25,
                ),
              )
            ],
          ),
          const SizedBox(height: 8),

          // 下線
          Container(
            width: MediaQuery.of(context).size.width,
            height: 1,
            color: const Color(0xFFB1B1B1),
          ),
        ],
      ),
    );
  }
}
