//mobile view

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/pages/home_page/bloc/home_bloc.dart';
import 'package:interview_app/pages/home_page/ui/widgets/my_custom_card.dart';
import 'package:interview_app/pages/home_page/ui/widgets/my_drawer.dart';

class MobileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listenWhen: (previous, current) => current is HomeActionState,
      buildWhen: (previous, current) => current is! HomeActionState,
      listener: (context, state) {
        if (state is CameraInterviewActionState) {
          context.push('/CameraInterview');
        } else if (state is StartTalkToAiActionState) {
          context.push('/startTalkToAi');
        } else if (state is LogoutSuccessActionState) {
          context.go('/');
        } else if (state is LogoutFailureActionState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Intervista AI",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
          ),
          drawer: MyDrawer(),
          backgroundColor: const Color.fromARGB(255, 234, 240, 249),
          body: SafeArea(child: _buildBody(context, state)),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is ApiKeyState) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading app configuration...'),
          ],
        ),
      );
    }

    if (state is ApiKeyFailureState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, size: 48, color: Color(0xFF3F51B5)),
              SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () =>
                    context.read<HomeBloc>().add(RetryApiKeysFetchRequested()),
                icon: Icon(Icons.refresh),
                label: Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          MyCustomCard(
            title: 'AI Interview',
            description:
                "Practice live interviews with AI, focusing on adaptive reasoning and real-time feedback. Get personalized suggestions for improvement",
            buttonText: 'Start interveiw',
            buttoncolor: const Color(0xFF3F51B5),
            icon: Icons.stream_sharp,
            backgroundColor: const Color.fromARGB(255, 219, 226, 246),
            onPressed: () =>
                context.read<HomeBloc>().add(CameraInterviewButtonClicked()),
          ),
        ],
      ),
    );
  }
}
