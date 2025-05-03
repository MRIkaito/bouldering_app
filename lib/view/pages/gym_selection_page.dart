import 'package:bouldering_app/view_model/facility_info_provider.dart';
import 'package:bouldering_app/view_model/gym_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GymSelectionPage extends ConsumerStatefulWidget {
  const GymSelectionPage({Key? key}) : super(key: key);

  @override
  GymSelectionPageState createState() => GymSelectionPageState();
}

class GymSelectionPageState extends ConsumerState<GymSelectionPage> {
  final TextEditingController _controller = TextEditingController();

  // 全ジムとフィルター済ジムのリスト
  List<Map<String, dynamic>> allGyms = [];
  List<Map<String, dynamic>> filteredGyms = [];

  @override
  void initState() {
    super.initState();
    // final gymRef = ref.read(gymProvider);
    final gymRef = ref.read(gymInfoProvider);
    gymRef.forEach((id, gym) {
      if (gym.gymName != null && gym.prefecture != null && gym.city != null) {
        allGyms.add({
          'id': id,
          'name': gym.gymName,
          'location': '${gym.prefecture}${gym.city}'
        });
      }
    });
    filteredGyms = List.from(allGyms);
  }

  void _filterGyms(String query) {
    setState(() {
      filteredGyms = allGyms
          .where(
              (gym) => gym['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ジム検索', style: TextStyle(color: Colors.black)),
        elevation: 0.0,
        backgroundColor: const Color(0x00FEF7FF),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 検索ボックス
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'エリア・施設名・キーワード',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: _filterGyms,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      filteredGyms = List.from(allGyms);
                    });
                  },
                  child:
                      const Text('クリア', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),

          // ジムリスト表示
          Expanded(
            child: ListView.builder(
              itemCount: filteredGyms.length,
              itemBuilder: (context, index) {
                final gym = filteredGyms[index];
                return ListTile(
                  title: Text(gym['name']),
                  subtitle: Text(gym['location']),
                  onTap: () async {
                    final gymId = gym['id'].toString();
                    final gymInfo =
                        await ref.read(facilityInfoProvider(gymId).future);

                    if (gymInfo != null) {
                      await context.push('/FacilityInfo/$gymId');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("ジム情報の取得に失敗しました")),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
