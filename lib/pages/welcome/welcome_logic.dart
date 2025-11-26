import 'dart:async';

import 'package:get/get.dart';

import '../../routers/routes.dart';
import '../../utils/utils.dart';
import 'welcome_state.dart';

class WelcomeLogic extends GetxController {
  final WelcomeState state = WelcomeState();
  final RxInt countdown = 3.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startCountdown();
  }

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
        PrefsUtil().setIsFirstOpen(false);
        Get.offNamed(AppRoutes.compress);
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
