import 'package:bouldering_app/view/components/boul_log.dart';
import 'package:bouldering_app/view/components/switcher_tab.dart';
import 'package:flutter/material.dart';

class BoulLogPage extends StatelessWidget {
  const BoulLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body: SafeArea(
        child: Column(
          children: [
            // タブバー部分
            const SwitcherTab(leftTabName: "みんなのボル活", rightTabName: "お気に入り"),

            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return const BoulLog();
                    },
                  ),
                  ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return const BoulLog();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
