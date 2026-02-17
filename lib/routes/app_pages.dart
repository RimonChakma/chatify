import 'package:chatify/controller/auth/profile_controller.dart';
import 'package:chatify/views/auth/login_view.dart';
import 'package:chatify/views/auth/profile_view.dart';
import 'package:chatify/views/auth/registration_view.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../views/auth/forget_password_view.dart';
import '../views/auth/main_view.dart';
import '../views/auth/splash_view.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashView(),),
    GetPage(name: AppRoutes.main, page: () => const MainView(),),
    GetPage(name: AppRoutes.login, page: () => const LoginView(),),
    GetPage(name: AppRoutes.register, page: () => const RegistrationView(),),
    GetPage(name: AppRoutes.forgetPassword, page: () => const ForgetPasswordView(),),
    GetPage(
      name: AppRoutes.profile,
      page: () =>  ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      },)
    ),


  ];
}