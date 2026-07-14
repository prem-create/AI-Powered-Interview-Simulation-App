import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/bloc/camera_interview_bloc.dart';
import 'package:interview_app/pages/camera_interview_page/ui/mobile_ui/initial_mobile_ui.dart';
import 'package:interview_app/pages/camera_interview_page/ui/mobile_ui/loading_success_mobile_ui.dart';
import 'package:interview_app/pages/camera_interview_page/ui/utils/initial_interview_detials_alert_box.dart';
import 'package:interview_app/pages/resutl_History_page/histroy_page.dart';

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
        if (state is AskInterviewDetailsState) {
          InitialInterviewDetialsAlertBox(
            candidateName: candidateName,
            interviewTopic: interviewTopic,
            parentContext: context,
          );
        }
      },
      builder: (context, state) {
        //loading
        if (state is CameraInterviewLoadingState) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state is CameraInterviewResultState) {
          // context.go('cameraInterviewResultPage');
          return HistroyPage(result: state.result);
        }
        //loading error
        else if (state is CameraInterviewLoadingErrorState) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Something went wrong'),
              actions: state.canRetryAction
                  ? [
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          context.read<CameraInterviewBloc>().add(
                            RetryLastInterviewActionEvent(),
                          );
                        },
                      ),
                    ]
                  : null,
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (state.canRetryAction) ...[
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () {
                              context.read<CameraInterviewBloc>().add(
                                RetryLastInterviewActionEvent(),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        //loading success
        else if (state is CameraInterviewLoadingSuccessState) {
          context.read<CameraInterviewBloc>().add(
            SpeakTtsEvent(text: state.question),
          );
          return LoadingSuccessMobileUi(state: state);
        }
        //inital view
        else if (state is CameraInterviewInitial) {
          return InitialMobileUi();
        }
        //if no state matches or wrong state is emitted
        else {
          return Scaffold(
            body: Center(child: Text('An unexpected error occurred.')),
          );
        }
      },
    );
  }
}
