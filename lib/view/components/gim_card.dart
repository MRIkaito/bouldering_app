import 'package:bouldering_app/view/components/gim_category.dart';
import 'package:flutter/material.dart';

class GimCard extends StatelessWidget {
  final String gymName;
  final String gymLocation;
  final int ikitaiCount;
  final int boulCount;

  const GimCard({
    super.key,
    this.gymName = 'Dボルダリング綱島',
    this.gymLocation = '[神奈川県]',
    this.ikitaiCount = 200,
    this.boulCount = 400,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                gymName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                gymLocation,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              GimCategory(gimCategory: 'ボルダリング', colorCode: 0xFFFF0F00),
              SizedBox(width: 8),
              GimCategory(gimCategory: 'キッズ', colorCode: 0xFFFFA115),
            ],
          ),
          const SizedBox(height: 8),

          // 更新：横スクロールできるようにした。
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Placeholder for gym images, using Flutter logo for demo purposes
                // ジムの紹介写真を配置する．今は適当な画像でデモ表示する
                ...List.generate(
                    3,
                    (index) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            // image: AssetImage("lib/view/assets/map_image.png"),
                            child: Image.asset(
                              'lib/view/assets/map_image.png',
                              width: 132,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.currency_yen, size: 18),
              const SizedBox(width: 4),
              const Text('1400円〜'),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 4),
              const Text('営業中'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
          Container(
            width: MediaQuery.of(context).size.width,
            height: 1,
            color: Color(0xFFB1B1B1),
          ),
        ],
      ),
    );
  }
}
