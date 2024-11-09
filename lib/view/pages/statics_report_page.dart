import 'package:bouldering_app/view/components/statics_report.dart';
import 'package:flutter/material.dart';

class StaticsReportPage extends StatelessWidget {
  const StaticsReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              StaticsReport(),
              SizedBox(
                height: 8,
              ),
              StaticsReport(
                backgroundColor: 0xFF8D8D8D,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
