import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'welcome_logic.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(WelcomeLogic());
    final state = logic.state;

    return SizedBox(
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().screenHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          state.buildBackdrop(),
          state.buildWelcomeFont(),
          _buildCountdownTimer(logic.countdown),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer(RxInt countdown) {
    return Positioned(
      top: 20.h,
      right: 20.w,
      child: Obx(() {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${countdown.value}s',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }
}
