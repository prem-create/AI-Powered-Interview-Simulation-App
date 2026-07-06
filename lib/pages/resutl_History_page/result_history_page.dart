import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_history_item.dart';
import 'package:interview_app/pages/camera_interview_page/repo/interview_persistence_repository.dart';

class ResultHistoryPage extends StatefulWidget {
  const ResultHistoryPage({super.key});

  @override
  State<ResultHistoryPage> createState() => _ResultHistoryPageState();
}

class _ResultHistoryPageState extends State<ResultHistoryPage> {
  final InterviewPersistenceRepository _repository =
      InterviewPersistenceRepository();
  late final Stream<List<InterviewHistoryItem>> _historyStream;

  @override
  void initState() {
    super.initState();
    _historyStream = _repository.watchInterviewHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Result History'), centerTitle: true),
      body: StreamBuilder<List<InterviewHistoryItem>>(
        stream: _historyStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _HistoryMessage(
              message: 'Could not load interview history. Please try again.',
            );
          }

          final interviews = snapshot.data ?? const <InterviewHistoryItem>[];
          if (interviews.isEmpty) {
            return const _HistoryMessage(message: 'No history found');
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = _crossAxisCountForWidth(
                constraints.maxWidth,
              );

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: _cardHeightForWidth(constraints.maxWidth),
                ),
                itemCount: interviews.length,
                itemBuilder: (context, index) {
                  return _InterviewHistoryCard(interview: interviews[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  int _crossAxisCountForWidth(double width) {
    if (width >= 1100) return 3;
    if (width >= 700) return 2;
    return 1;
  }

  double _cardHeightForWidth(double width) {
    if (width >= 1100) return 180.h;
    if (width >= 700) return 330.h;
    return 280.h;
  }
}

class _InterviewHistoryCard extends StatelessWidget {
  const _InterviewHistoryCard({required this.interview});

  final InterviewHistoryItem interview;

  @override
  Widget build(BuildContext context) {
    final hasResult = interview.hasResult;

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: hasResult
            ? () =>
                  context.push('/historyPage', extra: interview.resultMarkdown)
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusIndicator(hasResult: hasResult),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasResult ? 'Completed' : 'Interview not ended',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: hasResult ? Colors.green.shade700 : Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                interview.interviewTopic.isEmpty
                    ? 'Untitled interview'
                    : interview.interviewTopic,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _detailsText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              hasResult
                  ? OutlinedButton(
                      onPressed: () => context.push(
                        '/historyPage',
                        extra: interview.resultMarkdown,
                      ),
                      child: Text(
                        'See Detailed Report',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green.shade700,
                        ),
                      ),
                    )
                  : Text(
                      'Result not available because this interview is still in progress.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                      ),
                    ),
              const SizedBox(height: 12),
              Text(
                _dateText(interview.updatedAt ?? interview.createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _detailsText {
    final parts = [
      interview.candidateName,
      interview.interviewType,
      interview.difficultyLevel,
      '${interview.answeredQuestionsCount} answered',
    ].where((value) => value.trim().isNotEmpty).toList(growable: false);

    return parts.join(' | ');
  }

  String _dateText(DateTime? dateTime) {
    if (dateTime == null) return 'Date unavailable';

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return 'Updated $day/$month/$year';
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.hasResult});

  final bool hasResult;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: hasResult ? Colors.green : Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _HistoryMessage extends StatelessWidget {
  const _HistoryMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
