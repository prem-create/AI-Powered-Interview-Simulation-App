import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_app/core/extensions/sized_box_extension.dart';
import 'package:interview_app/pages/camera_interview_page/ui/utils/bottom_bar.dart';

class LoadingSuccessMobileUi extends StatelessWidget {
  final state;
  final TextEditingController answerController = TextEditingController();

  LoadingSuccessMobileUi({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_sharp),
        ),
        title: Center(
          child: Text(
            'Camera Interview',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 234, 240, 249),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final heroSize = _heroSizeForWidth(constraints.maxWidth);

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 16.w),
                      child: Center(
                        child: SizedBox(
                          width: heroSize,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(
                                    'assets/interview.webp',
                                    fit: BoxFit.cover,
                                  ),
                                  Center(
                                    child: Text(
                                      "Camera feature coming soon",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ai Response(Question)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Divider(),
                              Text(
                                '${state.question}',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 50, 48, 48),
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    10.ht,
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: BottomBar(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _heroSizeForWidth(double width) {
    if (width >= 700) return 420;
    return width - 30.w;
  }
}
