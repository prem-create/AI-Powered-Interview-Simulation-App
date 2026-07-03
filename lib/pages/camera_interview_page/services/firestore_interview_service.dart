import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_persistence_exception.dart';
import 'package:interview_app/pages/camera_interview_page/models/interview_session_details.dart';

class FirestoreInterviewService {
  FirestoreInterviewService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  Future<String> createInterview(InterviewSessionDetails details) async {
    try {
      final document = await _currentUserInterviews.add({
        ...details.toMap(),
        'resultMarkdown': null,
        'status': 'in_progress',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return document.id;
    } on InterviewPersistenceException {
      rethrow;
    } on FirebaseException catch (error) {
      throw InterviewPersistenceException(_messageForFirebaseCode(error.code));
    } catch (_) {
      throw const InterviewPersistenceException(
        'Could not save interview details. Please try again.',
      );
    }
  }

  Future<void> saveResultMarkdown({
    required String interviewId,
    required String resultMarkdown,
  }) async {
    try {
      await _currentUserInterviews.doc(interviewId).update({
        'resultMarkdown': resultMarkdown,
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on InterviewPersistenceException {
      rethrow;
    } on FirebaseException catch (error) {
      throw InterviewPersistenceException(_messageForFirebaseCode(error.code));
    } catch (_) {
      throw const InterviewPersistenceException(
        'Could not save interview result. Please try again.',
      );
    }
  }

  CollectionReference<Map<String, dynamic>> get _currentUserInterviews {
    final userId = _firebaseAuth.currentUser?.uid;

    if (userId == null) {
      throw const InterviewPersistenceException(
        'Please log in before starting an interview.',
      );
    }

    return _firestore.collection('users').doc(userId).collection('interviews');
  }

  String _messageForFirebaseCode(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to save this interview.';
      case 'unavailable':
        return 'Could not connect to Firestore. Please try again.';
      case 'not-found':
        return 'This interview session could not be found.';
      default:
        return 'Could not save interview data. Please try again.';
    }
  }
}
