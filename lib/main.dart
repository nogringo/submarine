import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/app_routes.dart';
import 'package:submarine/config.dart';
import 'package:submarine/middlewares/router_must_be_logged_in_middleware.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/screens/create_note/create_note_page.dart';
import 'package:submarine/screens/password_manager/password_manager_page.dart';
import 'package:submarine/screens/signin/signin_page.dart';
import 'package:submarine/screens/create_password/create_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(Repository());
  await Repository.to.loadApp();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: appTitle,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      getPages: [
        GetPage(name: AppRoutes.signIn, page: () => SigninPage()),
        GetPage(
          name: AppRoutes.passwordManager,
          middlewares: [RouterMustBeLoggedInMiddleware()],
          page: () => PasswordManagerPage(),
        ),
        GetPage(
          name: AppRoutes.createPassword,
          middlewares: [RouterMustBeLoggedInMiddleware()],
          page: () => CreatePasswordPage(),
        ),
        GetPage(
          name: AppRoutes.createNote,
          middlewares: [RouterMustBeLoggedInMiddleware()],
          page: () => CreateNotePage(),
        ),
      ],
    );
  }
}
