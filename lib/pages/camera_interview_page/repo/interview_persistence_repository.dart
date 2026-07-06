import 'package:interview_app/pages/camera_interview_page/models/interview_scorecard_entry.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_history_item.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_session_details.dart';
import 'package:interview_app/pages/camera_interview_page/services/firestore_interview_service.dart';

class InterviewPersistenceRepository {
  InterviewPersistenceRepository({FirestoreInterviewService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreInterviewService();

  final FirestoreInterviewService _firestoreService;

  Future<String> createInterviewSession(InterviewSessionDetails details) {
    return _firestoreService.createInterview(details);
  }

  Future<void> saveAnswerTurn({
    required String interviewId,
    required int turnNumber,
    required InterviewScorecardEntry scorecardEntry,
  }) {
    return _firestoreService.saveAnswerTurn(
      interviewId: interviewId,
      turnNumber: turnNumber,
      scorecardEntry: scorecardEntry,
    );
  }

  Future<void> saveResultMarkdown({
    required String interviewId,
    required String resultMarkdown,
  }) {
    return _firestoreService.saveResultMarkdown(
      interviewId: interviewId,
      resultMarkdown: resultMarkdown,
    );
  }

  Stream<List<InterviewHistoryItem>> watchInterviewHistory() {
    return _firestoreService.watchInterviewHistory();
  }
}
