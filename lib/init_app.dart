import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'api/api_client.dart';
import 'service/oauth_service.dart';
import 'utils/utils.dart';
import 'values/values.dart';

/// App 初始化：绑定 Flutter 引擎、偏好存储、核心服务与网络客户端。
Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1080, 680),
      minimumSize: Size(800, 600),
      center: true,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      fullScreen: false,
      title: AppStrings.appName,
      windowButtonVisibility: true,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await PrefsUtil.ensureInitialized();
  ScreenUtil.ensureScreenSize();

  if (!Get.isRegistered<OauthService>()) {
    await Get.putAsync(() async => OauthService(), permanent: true);
  }

  if (!Get.isRegistered<ApiClient>()) {
    Get.put(ApiClient(), permanent: true);
  }

  Get.log('应用初始化完成');
}
