import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CameraInterviewResultPage extends StatelessWidget {
  final String result;
  const CameraInterviewResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('result'),),
      body: Text(result),
    );
  }
}
