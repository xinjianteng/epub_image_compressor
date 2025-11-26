// 应用入口：全局依赖绑定、刷新配置、路由挂载与日志输出。
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'init_app.dart';
import 'routers/routes.dart';
import 'service/oauth_service.dart';
import 'utils/logger.dart';
import 'utils/prefs_util.dart';
import 'values/values.dart';

OauthService get oauthService => Get.find<OauthService>();

Future<void> main() async {
  await initApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: AppDimens.deviceSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => RefreshConfiguration(
        headerBuilder: () => const ClassicHeader(
          height: 45.0,
          releaseText: '松开刷新',
          refreshingText: '刷新中...',
          completeText: '刷新完成',
          idleText: '下拉刷新',
        ),
        footerBuilder: () => const ClassicFooter(
          loadStyle: LoadStyle.ShowWhenLoading,
          completeDuration: Duration(milliseconds: 100),
          canLoadingText: '松开加载更多',
          noDataText: '没有更多数据了',
          loadingText: '加载中...',
          idleText: '上拉加载',
        ),
        hideFooterWhenNotFull: true,
        headerTriggerDistance: 80.h,
        maxOverScrollExtent: 100.h,
        footerTriggerDistance: 150.h,
        maxUnderScrollExtent: 0,
        enableScrollWhenRefreshCompleted: true,
        enableLoadingWhenFailed: true,
        enableBallisticLoad: true,
        child: GetMaterialApp(

          debugShowCheckedModeBanner: false,
          title: AppStrings.appName,
          initialBinding: BindingsBuilder(() {
            Get.putAsync<OauthService>(() async {
              await PrefsUtil.ensureInitialized();
              return OauthService();
            }, permanent: true);
          }),
          initialRoute: AppRoutes.welcome,
          getPages: AppPages.routes,
          unknownRoute: AppPages.unknownRoute,
          builder: FlutterSmartDialog.init(),
          navigatorObservers: [AppPages.observer, FlutterSmartDialog.observer],
          enableLog: true,
          logWriterCallback: (String text, {bool isError = false}) {
            Logger().log(text, isError: isError);
          },
        ),
      ),
    );
  }
}
