import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class CameraInterviewResultPage extends StatelessWidget {
  final String result;
  const CameraInterviewResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('result'),),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Markdown(data: result),
      ),
    );
  }
}
