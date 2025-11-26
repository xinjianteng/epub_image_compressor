import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/values/values.dart';

class WelcomeState {
  WelcomeState();

  Widget buildBackdrop() {
    final DateTime now = DateTime.now();
    final int dayOfWeek = now.weekday;

    String imagePath;
    switch (dayOfWeek) {
      case 1:
        imagePath = 'assets/images/splash_time_monday.webp';
        break;
      case 2:
        imagePath = 'assets/images/splash_time_tuesday.webp';
        break;
      case 3:
        imagePath = 'assets/images/splash_time_wednesday.webp';
        break;
      case 4:
        imagePath = 'assets/images/splash_time_thursday.webp';
        break;
      case 5:
        imagePath = 'assets/images/splash_time_friday.webp';
        break;
      case 6:
        imagePath = 'assets/images/splash_time_saturday.webp';
        break;
      case 7:
        imagePath = 'assets/images/splash_time_sunday.webp';
        break;
      default:
        imagePath = 'assets/images/splash_time_default.webp';
    }

    return Container(
      width: ScreenUtil().screenWidth,
      height: ScreenUtil().scaleHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C1C28), Color(0xFF232940)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }

  Widget buildWelcomeFont() {
    return Positioned(
      top: 210.h,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/splash_logo.png',
            width: 205.w,
            height: 87.h,
            errorBuilder: (_, __, ___) => const FlutterLogo(size: 72),
          ),
          SizedBox(height: 12.h),
          Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: 20.sp,
              color: const Color(0xFFFFFFFF),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AppStrings.appTagline,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFFECECEC),
            ),
          ),
        ],
      ),
    );
  }
}
