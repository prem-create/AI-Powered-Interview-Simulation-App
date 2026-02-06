import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/core/extensions/sized_box_extension.dart';
import 'package:interview_app/pages/mcq_page/models/questions.dart';
// import '/screens/quiz_screen.dart';
// import '/widgets/next_button.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SCORE PAGE',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        backgroundColor: const Color.fromARGB(255, 245, 206, 114),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 97, 98, 100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Your Score: ',
              style: TextStyle(fontSize: 34, fontWeight: FontWeight.w500),
            ),
            30.ht,
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 250,
                  width: 250,
                  child: CircularProgressIndicator(
                    strokeWidth: 10,
                    value: score / 9,
                    color: Colors.green,
                    backgroundColor: Colors.white,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      score.toString(),
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${(score / questions.length * 100).round()}%',
                      style: const TextStyle(fontSize: 25),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// 