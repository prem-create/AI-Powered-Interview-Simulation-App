import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class HistroyPage extends StatelessWidget {
  final String result;
  const HistroyPage({super.key, required this.result});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Interview Result'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Markdown(data: result),
      ),
    );
  }
}
