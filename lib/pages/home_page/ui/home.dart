import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:interview_app/pages/home_page/bloc/home_bloc.dart';
import 'package:interview_app/pages/home_page/ui/desktop_ui/desktop_view.dart';
import 'package:interview_app/pages/home_page/ui/mobile_ui/mobile_view.dart';
import 'package:responsive_builder/responsive_builder.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = HomeBloc();
        bloc.add(ApiKeyEvent());
        return bloc;
      },
      child: ScreenTypeLayout.builder(
        mobile: (context) => MobileView(),
        desktop: (_) => DesktopView(),
      ),
    );
  }
}
