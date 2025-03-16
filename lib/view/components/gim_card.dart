// import 'package:bouldering_app/view/components/gim_category.dart';
// import 'package:flutter/material.dart';

// class GimCard extends StatelessWidget {
//   final String gymName;
//   final String gymLocation;
//   final int ikitaiCount;
//   final int boulCount;

//   const GimCard({
//     super.key,
//     this.gymName = 'Dボルダリング綱島',
//     this.gymLocation = '[神奈川県]',
//     this.ikitaiCount = 200,
//     this.boulCount = 400,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Text(
//                 gymName,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 gymLocation,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           const Row(
//             children: [
//               GimCategory(gimCategory: 'ボルダリング', colorCode: 0xFFFF0F00),
//               SizedBox(width: 8),
//               GimCategory(gimCategory: 'キッズ', colorCode: 0xFFFFA115),
//             ],
//           ),
//           const SizedBox(height: 8),

//           // 更新：横スクロールできるようにした。
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Placeholder for gym images, using Flutter logo for demo purposes
//                 // ジムの紹介写真を配置する．今は適当な画像でデモ表示する
//                 ...List.generate(
//                     3,
//                     (index) => Padding(
//                           padding: const EdgeInsets.only(right: 8.0),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             // image: AssetImage("lib/view/assets/map_image.png"),
//                             child: Image.asset(
//                               'lib/view/assets/map_image.png',
//                               width: 132,
//                               height: 100,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         )),
//               ],
//             ),
//           ),
//           const SizedBox(height: 8),
//           Row(
//             children: [
//               const Icon(Icons.currency_yen, size: 18),
//               const SizedBox(width: 4),
//               const Text('1400円〜'),
//               const SizedBox(width: 16),
//               const Icon(Icons.access_time, size: 18),
//               const SizedBox(width: 4),
//               const Text('営業中'),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const Text(
//                 'イキタイ',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 '$ikitaiCount',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                   height: 1.25,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               const Text(
//                 'ボル活',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//               ),
//               const SizedBox(width: 4),
//               Text(
//                 '$boulCount',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                   height: 1.25,
//                 ),
//               )
//             ],
//           ),
//           const SizedBox(height: 8),
//           Container(
//             width: MediaQuery.of(context).size.width,
//             height: 1,
//             color: Color(0xFFB1B1B1),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:bouldering_app/view/components/gim_category.dart';
import 'package:dartz/dartz.dart';
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
          Row(
            children: [
              // ジム名
              Text(
                gymName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),

              // 所在県
              Text(
                gymPrefecture,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ジムカテゴリ
          Row(
            children: [
              if (isBoulderingGym) ...[
                const GimCategory(gimCategory: 'ボルダリング', colorCode: 0xFFF44336),
                const SizedBox(width: 8),
              ],
              if (isBoulderingGym) ...[
                const GimCategory(
                    gimCategory: 'リード',
                    colorCode: 0xFFFF0F00), // TODO：下記、colorCodeを変更する
                const SizedBox(width: 8),
              ],
              if (isBoulderingGym) ...[
                const GimCategory(
                    gimCategory: 'スピード',
                    colorCode: 0xFFFF0F00), // TODO：下記、colorCodeを変更する
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // ジム写真
          // TODO：値をもらうようにする
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
                                  ); // エラー時も「写真なし」を表示
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
                    ], // gymPhotos が null または空のときに「写真なし」を表示
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
