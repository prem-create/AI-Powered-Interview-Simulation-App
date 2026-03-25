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
        child: Column(
          children: [
            //camera placeholder
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(15.w),
                    child: Container(
                      width: double.infinity,
                      // height: 40.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage('assets/interview.webp'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Camera feature coming soon",
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //Ai response
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10.w, right: 10.w),
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
                        // 10.ht,
                        Divider(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              child: Text(
                                //.first means first postition in list or equal to [0]
                                '${state.question}',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    50,
                                    48,
                                    48,
                                  ),
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            10.ht,

            //call of icon button
            Padding(
              padding:  EdgeInsets.only(bottom:10.h),
              child: BottomBar(),
            ),
          ],
        ),
      ),
    );
  }
}
