import 'package:interview_app/pages/mcq_page/models/question.dart';


const List<Question> questions = [
  Question(
    question: '1. Which widget is the root of most Flutter apps?',
    correctAnswerIndex: 1,
    options: [
      'a) Container',
      'b) MaterialApp',
      'c) Scaffold',
      'd) Column',
    ],
  ),
  Question(
    question: '2. What is the main purpose of a "StatefulWidget"?',
    correctAnswerIndex: 2,
    options: [
      'a) To display static text',
      'b) To improve performance only',
      'c) To handle data that changes during runtime',
      'd) To create a database connection',
    ],
  ),
  Question(
    question: '3. In Firebase, which service is used for NoSQL cloud storage of JSON data?',
    correctAnswerIndex: 0,
    options: [
      'a) Cloud Firestore',
      'b) Cloud Storage',
      'c) Firebase Hosting',
      'd) Firebase Auth',
    ],
  ),
  Question(
    question: '4. What command is used to fetch project dependencies in Flutter?',
    correctAnswerIndex: 3,
    options: [
      'a) flutter build',
      'b) flutter upgrade',
      'c) flutter run',
      'd) flutter pub get',
    ],
  ),
  Question(
    question: '5. Which Firebase feature allows you to authenticate users via Email/Password or Google?',
    correctAnswerIndex: 2,
    options: [
      'a) Remote Config',
      'b) Cloud Functions',
      'c) Firebase Authentication',
      'd) Realtime Database',
    ],
  ),
  Question(
    question: '6. What is "Tree Shaking" in Flutter?',
    correctAnswerIndex: 1,
    options: [
      'a) Moving widgets to a different file',
      'b) Removing unused code during compilation',
      'c) A method to refresh the UI',
      'd) Fixing layout errors',
    ],
  ),
  Question(
    question: '7. Which function is called to redraw a StatefulWidget?',
    correctAnswerIndex: 0,
    options: [
      'a) setState()',
      'b) build()',
      'c) initState()',
      'd) reload()',
    ],
  ),
  Question(
    question: '8. In Firestore, what are the two main organizational units for data?',
    correctAnswerIndex: 1,
    options: [
      'a) Tables and Rows',
      'b) Collections and Documents',
      'c) Folders and Files',
      'd) Keys and Values',
    ],
  ),
  Question(
    question: '9. What is the name of the programming language used to build Flutter apps?',
    correctAnswerIndex: 3,
    options: [
      'a) Java',
      'b) Kotlin',
      'c) Swift',
      'd) Dart',
    ],
  ),
];