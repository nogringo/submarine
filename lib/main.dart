import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:submarine/app_routes.dart';
import 'package:submarine/config.dart';
import 'package:submarine/middlewares/router_must_be_logged_in_middleware.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/screens/create_note/create_note_page.dart';
import 'package:submarine/screens/password_manager/password_manager_page.dart';
import 'package:submarine/screens/signin/signin_page.dart';
import 'package:submarine/screens/create_password/create_password_page.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_theme/system_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && GetPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }

  await SystemTheme.accentColor.load();

  Get.put(Repository());
  await Repository.to.loadApp();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(
      builder: (context, accent) {
        final supportAccentColor = defaultTargetPlatform.supportsAccentColor;
        Color accentColor = supportAccentColor
            ? accent.accent
            : accent.defaultAccentColor;
        if (kIsWeb) accentColor = const Color(0xFF1F3C88);

        ThemeData getTheme([Brightness? brightness]) {
          brightness = brightness ?? Brightness.light;
          final bool isLightTheme = brightness == Brightness.light;

          final colorScheme = ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: brightness,
          );

          return ThemeData(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarBrightness: isLightTheme
                    ? Brightness.dark
                    : Brightness.light,
                systemNavigationBarColor: colorScheme.surface,
                systemNavigationBarIconBrightness: isLightTheme
                    ? Brightness.dark
                    : Brightness.light,
              ),
            ),
            colorScheme: colorScheme,
            brightness: brightness,
          );
        }

        final app = GetMaterialApp(
          title: appTitle,
          theme: getTheme(),
          darkTheme: getTheme(Brightness.dark),
          themeMode: ThemeMode.system,
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
        
        if (!kIsWeb && GetPlatform.isDesktop) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: DragToResizeArea(child: app),
          );
        }
        
        return app;
      },
    );
  }
}
