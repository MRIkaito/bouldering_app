import 'package:bouldering_app/view/pages/logined_my_page.dart';
import 'package:bouldering_app/view/pages/unlogined_my_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bouldering_app/view_model/user_provider.dart';

class MyPageGate extends ConsumerWidget {
  const MyPageGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return const UnloginedMyPage();
    } else {
      return const LoginedMyPage();
    }
  }
}
