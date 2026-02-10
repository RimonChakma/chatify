import 'package:get_x/get.dart';
import 'package:get_x/get_core/src/get_main.dart';

import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView(),);

  ];
}