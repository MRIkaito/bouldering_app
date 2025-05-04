// import 'package:bouldering_app/view/components/gim_category.dart';
// import 'package:bouldering_app/view_model/gym_info_provider.dart';
// import 'package:bouldering_app/view_model/utility/is_open.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class SearchGymOnMapPage extends ConsumerStatefulWidget {
//   const SearchGymOnMapPage({super.key});

//   @override
//   _SearchGymOnMapPageState createState() => _SearchGymOnMapPageState();
// }

// class _SearchGymOnMapPageState extends ConsumerState<SearchGymOnMapPage> {
//   Set<Marker> _markers = {};
//   final LatLng _center = const LatLng(35.681236, 139.767125); // 東京駅
//   late GoogleMapController mapController;
//   late BitmapDescriptor customGymMarker;

//   @override
//   void initState() {
//     super.initState();
//   }

//   void _onMapCreated(GoogleMapController controller) async {
//     mapController = controller;

//     // マップスタイルを設定
//     final style = await rootBundle.loadString('assets/map_style.json');
//     mapController.setMapStyle(style);

//     // ピン画像を読み込み（小さめに表示したい場合）
//     final icon = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(24, 24)), // ★ ピン画像の表示サイズ
//       'assets/pin_64.png', // ★ 小さい画像を指定
//     );
//     customGymMarker = icon;

//     // ジム情報を取得
//     final gymMap = ref.read(gymInfoProvider);
//     final gyms = gymMap.values;
//     for (final gym in gyms) {
//       print('📍 ${gym.gymName}: (${gym.latitude}, ${gym.longitude})');
//     }

//     final markers = gyms
//         .where((gym) =>
//             gym.latitude != null &&
//             gym.longitude != null &&
//             gym.latitude != 0.0 &&
//             gym.longitude != 0.0)
//         .map((gym) {
//       print('✅ マーカー登録: ${gym.gymName} (${gym.latitude}, ${gym.longitude})');
//       return Marker(
//         markerId: MarkerId(gym.gymId.toString()),
//         position: LatLng(gym.latitude, gym.longitude),
//         icon: customGymMarker,
//         infoWindow: InfoWindow(
//           title: gym.gymName,
//           snippet: gym.prefecture,
//         ),
//       );
//     }).toSet();

//     setState(() {
//       _markers = markers;
//     });

//     // ピンが存在すればカメラ移動
//     if (markers.isNotEmpty) {
//       final bounds = _createLatLngBoundsFromMarkers(markers);
//       mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//     }
//   }

//   LatLngBounds _createLatLngBoundsFromMarkers(Set<Marker> markers) {
//     final latitudes = markers.map((m) => m.position.latitude);
//     final longitudes = markers.map((m) => m.position.longitude);

//     final southWest = LatLng(
//       latitudes.reduce((a, b) => a < b ? a : b),
//       longitudes.reduce((a, b) => a < b ? a : b),
//     );
//     final northEast = LatLng(
//       latitudes.reduce((a, b) => a > b ? a : b),
//       longitudes.reduce((a, b) => a > b ? a : b),
//     );

//     return LatLngBounds(southwest: southWest, northeast: northEast);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final gymMap = ref.watch(gymInfoProvider);
//     final gyms = gymMap.values.toList();

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: _onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: _center,
//               zoom: 14.5,
//             ),
//             markers: _markers,
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               color: Colors.white,
//               height: 260,
//               padding: const EdgeInsets.only(bottom: 8),
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: gyms.length,
//                 itemBuilder: (context, index) {
//                   final gym = gyms[index];

//                   final open = isOpen({
//                     'sun_open': gym.sunOpen ?? '-',
//                     'sun_close': gym.sunClose ?? '-',
//                     'mon_open': gym.monOpen ?? '-',
//                     'mon_close': gym.monClose ?? '-',
//                     'tue_open': gym.tueOpen ?? '-',
//                     'tue_close': gym.tueClose ?? '-',
//                     'wed_open': gym.wedOpen ?? '-',
//                     'wed_close': gym.wedClose ?? '-',
//                     'thu_open': gym.thuOpen ?? '-',
//                     'thu_close': gym.thuClose ?? '-',
//                     'fri_open': gym.friOpen ?? '-',
//                     'fri_close': gym.friClose ?? '-',
//                     'sat_open': gym.satOpen ?? '-',
//                     'sat_close': gym.satClose ?? '-',
//                   });

//                   return Container(
//                     width: MediaQuery.of(context).size.width * 0.8,
//                     margin: const EdgeInsets.all(8),
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black12,
//                           blurRadius: 4,
//                           offset: Offset(0, 2),
//                         )
//                       ],
//                     ),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             '${gym.gymName} [${gym.prefecture}]',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               if (gym.isBoulderingGym)
//                                 const Padding(
//                                   padding: EdgeInsets.only(right: 8.0),
//                                   child: GimCategory(
//                                     gimCategory: 'ボルダリング',
//                                     colorCode: 0xFFFF0F00,
//                                   ),
//                                 ),
//                               if (gym.isLeadGym)
//                                 const Padding(
//                                   padding: EdgeInsets.only(right: 8.0),
//                                   child: GimCategory(
//                                     gimCategory: 'リード',
//                                     colorCode: 0xFF00A24C,
//                                   ),
//                                 ),
//                               if (gym.isSpeedGym)
//                                 const GimCategory(
//                                   gimCategory: 'スピード',
//                                   colorCode: 0xFF0057FF,
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             width: double.infinity,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[300],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Center(child: Text('写真なし')),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               const Icon(Icons.currency_yen, size: 18),
//                               Text('${gym.minimumFee}〜'),
//                               const SizedBox(width: 16),
//                               const Icon(Icons.access_time, size: 18),
//                               Text(open ? 'OPEN' : 'CLOSE'),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// search_gym_on_map.dart（ピン押下で対象カードへスクロール + 地図中心移動 + ジム名タップで詳細ページ遷移）
import 'package:bouldering_app/view/components/gim_category.dart';
import 'package:bouldering_app/view_model/facility_info_provider.dart';
import 'package:bouldering_app/view_model/gym_info_provider.dart';
import 'package:bouldering_app/view_model/utility/is_open.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

class SearchGymOnMapPage extends ConsumerStatefulWidget {
  const SearchGymOnMapPage({super.key});

  @override
  _SearchGymOnMapPageState createState() => _SearchGymOnMapPageState();
}

class _SearchGymOnMapPageState extends ConsumerState<SearchGymOnMapPage> {
  Set<Marker> _markers = {};
  final LatLng _center = const LatLng(35.681236, 139.767125);
  late GoogleMapController mapController;
  late BitmapDescriptor customGymMarker;

  final ScrollController _scrollController = ScrollController();
  int _focusedGymIndex = -1;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    final style = await rootBundle.loadString('assets/map_style.json');
    mapController.setMapStyle(style);

    final icon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(24, 24)),
      'assets/pin_64.png',
    );
    customGymMarker = icon;

    final gymMap = ref.read(gymInfoProvider);
    final gyms = gymMap.values.toList();

    final markers = gyms
        .asMap()
        .entries
        .where((e) =>
            e.value.latitude != null &&
            e.value.longitude != null &&
            e.value.latitude != 0.0 &&
            e.value.longitude != 0.0)
        .map((entry) {
      final gym = entry.value;
      final index = entry.key;

      return Marker(
        markerId: MarkerId(gym.gymId.toString()),
        position: LatLng(gym.latitude, gym.longitude),
        icon: customGymMarker,
        onTap: () {
          setState(() {
            _focusedGymIndex = index;
          });
          _scrollToCard(index);
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(gym.latitude, gym.longitude), 15),
          );
        },
        infoWindow: InfoWindow(
          title: gym.gymName,
          snippet: gym.prefecture,
        ),
      );
    }).toSet();

    setState(() {
      _markers = markers;
    });

    if (markers.isNotEmpty) {
      final bounds = _createLatLngBoundsFromMarkers(markers);
      mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  void _scrollToCard(int index) {
    final width = MediaQuery.of(context).size.width * 0.8 + 16;
    _scrollController.animateTo(
      width * index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  LatLngBounds _createLatLngBoundsFromMarkers(Set<Marker> markers) {
    final latitudes = markers.map((m) => m.position.latitude);
    final longitudes = markers.map((m) => m.position.longitude);

    final southWest = LatLng(
      latitudes.reduce((a, b) => a < b ? a : b),
      longitudes.reduce((a, b) => a < b ? a : b),
    );
    final northEast = LatLng(
      latitudes.reduce((a, b) => a > b ? a : b),
      longitudes.reduce((a, b) => a > b ? a : b),
    );

    return LatLngBounds(southwest: southWest, northeast: northEast);
  }

  @override
  Widget build(BuildContext context) {
    final gymMap = ref.watch(gymInfoProvider);
    final gyms = gymMap.values.toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 14.5,
            ),
            markers: _markers,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              height: 260,
              padding: const EdgeInsets.only(bottom: 8),
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: gyms.length,
                itemBuilder: (context, index) {
                  final gym = gyms[index];

                  final open = isOpen({
                    'sun_open': gym.sunOpen ?? '-',
                    'sun_close': gym.sunClose ?? '-',
                    'mon_open': gym.monOpen ?? '-',
                    'mon_close': gym.monClose ?? '-',
                    'tue_open': gym.tueOpen ?? '-',
                    'tue_close': gym.tueClose ?? '-',
                    'wed_open': gym.wedOpen ?? '-',
                    'wed_close': gym.wedClose ?? '-',
                    'thu_open': gym.thuOpen ?? '-',
                    'thu_close': gym.thuClose ?? '-',
                    'fri_open': gym.friOpen ?? '-',
                    'fri_close': gym.friClose ?? '-',
                    'sat_open': gym.satOpen ?? '-',
                    'sat_close': gym.satClose ?? '-',
                  });

                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final gymId = gym.gymId.toString();
                              final gymInfo = await ref
                                  .read(facilityInfoProvider(gymId).future);

                              if (gymInfo != null) {
                                context.push('/FacilityInfo/$gymId');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('ジム情報の取得に失敗しました')),
                                );
                              }
                            },
                            child: Text(
                              '${gym.gymName} [${gym.prefecture}]',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (gym.isBoulderingGym)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: GimCategory(
                                    gimCategory: 'ボルダリング',
                                    colorCode: 0xFFFF0F00,
                                  ),
                                ),
                              if (gym.isLeadGym)
                                const Padding(
                                  padding: EdgeInsets.only(right: 8.0),
                                  child: GimCategory(
                                    gimCategory: 'リード',
                                    colorCode: 0xFF00A24C,
                                  ),
                                ),
                              if (gym.isSpeedGym)
                                const GimCategory(
                                  gimCategory: 'スピード',
                                  colorCode: 0xFF0057FF,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(child: Text('写真なし')),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.currency_yen, size: 18),
                              Text('${gym.minimumFee}〜'),
                              const SizedBox(width: 16),
                              const Icon(Icons.access_time, size: 18),
                              Text(open ? 'OPEN' : 'CLOSE'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
