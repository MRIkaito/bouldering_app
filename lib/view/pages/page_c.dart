import 'package:flutter/material.dart';

class PageC extends StatefulWidget {
  const PageC({super.key});

  @override
  State<PageC> createState() => _PageCState();
}

class _PageCState extends State<PageC> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('ページB'),
    );
  }
}
