import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/pages/camera_interview_page/bloc/camera_interview_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/ui/mobile_ui/initial_mobile_ui.dart';
import 'package:interview_app/pages/camera_interview_page/ui/mobile_ui/loading_success_mobile_ui.dart';
import 'package:interview_app/pages/camera_interview_page/ui/utils/initial_interview_detials_alert_box.dart';

class MobileUi extends StatelessWidget {
  const MobileUi({super.key});

  @override
  Widget build(BuildContext context) {
      final TextEditingController candidateName = TextEditingController();
    final TextEditingController interviewTopic = TextEditingController();
    return BlocConsumer<CameraInterviewBloc, CameraInterviewState>(
      listenWhen: (previous, current) => current is CameraInterviewActionState,
      buildWhen: (previous, current) => current is! CameraInterviewActionState,
      listener: (context, state) {
        if(state is AskInterviewDetailsState){
          InitialInterviewDetialsAlertBox(candidateName: candidateName, interviewTopic: interviewTopic, parentContext: context);
        }
      },
      builder: (context, state) {
        //loading
        if (state is CameraInterviewLoadingState) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        //loading error
        else if (state is CameraInterviewLoadingErrorState) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
              actions: [
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    context.pop();
                  },
                ),
              ],
            ),
            body: Center(child: Text('loading Error'))
            );
        }
        //loading success
        else if (state is CameraInterviewLoadingSuccessState) {
          return LoadingSuccessMobileUi(state: state);
        }
        //inital view
        else if (state is CameraInterviewInitial) {
          return InitialMobileUi();
        }
        //if no state matches or wrong state is emitted
        else {
          return Scaffold(body: Center(child: Text('state not matched Error')));
        }
      },
    );
  }
}
