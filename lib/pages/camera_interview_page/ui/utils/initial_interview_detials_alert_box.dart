import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:interview_app/pages/camera_interview_page/bloc/camera_interview_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/ui/utils/my_icon_elevated_button.dart';

Future<void> InitialInterviewDetialsAlertBox({
  required final TextEditingController? candidateName,
  required final TextEditingController? interviewTopic,

  required final BuildContext parentContext,
  String? difficultyLevel,
}) {
  return showDialog(
    context: parentContext,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Enter the Required details to proceed'),
            titlePadding: EdgeInsets.all(20),
            actions: [
              TextField(
                controller: candidateName,
                decoration: InputDecoration(label: Text('Name')),
              ),

              TextField(
                controller: interviewTopic,
                decoration: InputDecoration(label: Text('Interview Topic')),
              ),

              DropdownButton(
                value: difficultyLevel,
                hint: Text('Beginner, Intermediate, Advanced'),
                items: [
                  DropdownMenuItem(child: Text('Beginner'), value: 'Beginner'),
                  DropdownMenuItem(
                    child: Text('Intermediate'),
                    value: 'Intermediate',
                  ),
                  DropdownMenuItem(child: Text('Advanced'), value: 'Advanced'),
                ],
                onChanged: (value) {
                  setState(() => difficultyLevel = value);
                },
              ),

              MyIconElevatedButton(
                IconSize: 30,
                buttoncolor: Colors.green,
                iconData: Icons.forward_sharp,
                onPressed: () {
                  // check if user input data is null
                  if (candidateName!.text.isEmpty ||
                      difficultyLevel == null ||
                      interviewTopic!.text.isEmpty) {
                    showDialog(
                      context: parentContext,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Missing Required input'),
                          content: Text('enter all the details asked'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    Navigator.of(context).pop(); // Close the dialog first
                    parentContext.read<CameraInterviewBloc>().add(
                      StartCameraInterviewButtonTappedEvent(
                        InterviewTopic: interviewTopic.text,
                        candidateName: candidateName.text,
                        difficultyLevel: difficultyLevel.toString(),
                      ),
                    );
                  }
                },
                text: 'Proceed',
                textcolor: Colors.white,
              ),
            ],
          );
        },
      );
    },
  );
}
