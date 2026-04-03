import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/core/constants/constants.dart';

class ResultHistoryPage extends StatefulWidget {
  const ResultHistoryPage({super.key});

  @override
  State<ResultHistoryPage> createState() => _ResultHistoryPageState();
}

class _ResultHistoryPageState extends State<ResultHistoryPage> {
  @override
  Widget build(BuildContext context) {
    int count = resultHistory.length;
    return Scaffold(
      appBar: AppBar(title: Text("Result History")),
      body: count == 0
          ? Center(child: Text("No History Found"))
          : ListView.builder(
              itemCount: count,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    context.push("/historyPage", extra: resultHistory[index]);
                  },
                  child: Card(
                    margin: EdgeInsets.all(16),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            ' ${resultHistory[index]}',
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle( fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
