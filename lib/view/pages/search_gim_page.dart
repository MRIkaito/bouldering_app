import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// 遷移先のページ
@RoutePage()
class SearchGimPage extends StatelessWidget {
  const SearchGimPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('別のページ')),
      body: Center(child: Text('別のページへ遷移しました')),
    );
  }
}
