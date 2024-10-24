import 'package:auto_route/auto_route.dart';
import 'package:bouldering_app/view/pages/unlogined_my_page.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:() {
        Navigator.push(context, 
          MaterialPageRoute(
            // builder: (context) => SettingPage(),
            builder: (context) => UnloginedMyPage(),
          ),
        );
      },
    );
  }
}
