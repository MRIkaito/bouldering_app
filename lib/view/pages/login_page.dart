import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// 別のページとして例を作成
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('別のページに遷移しました')),
    );
  }
}
