import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../pages/pages.dart';
import 'middlewares/middlewares.dart';
import 'routes.dart';

class AppPages {
  static final RouteObserver<Route> observer = RouteObservers();
  static List<String> history = [];

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomePage(),
      transition: Transition.native,
      middlewares: [
        RouteWelcomeMiddleware(priority: 1),
      ],
    ),

    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: Transition.native,
    ),


    GetPage(
      name: AppRoutes.compress,
      page: () => const CompressPage(),
      transition: Transition.fadeIn,
    ),


    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.setting,
      page: () => const SettingPage(),
    ),
    GetPage(
      name: AppRoutes.aboutApp,
      page: () => const AboutPage(),
    ),

    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
    ),
  ];

  static final GetPage unknownRoute = GetPage(
    name: AppRoutes.notFound,
    page: () => const NotFoundPage(),
  );
}
