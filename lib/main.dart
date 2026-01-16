import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:sembast_cache_manager/sembast_cache_manager.dart';
import 'package:submarine/app_routes.dart';
import 'package:submarine/config.dart';
import 'package:submarine/get_database.dart';
import 'package:submarine/middlewares/router_must_be_logged_in_middleware.dart';
import 'package:submarine/repository.dart';
import 'package:submarine/screens/create_note/create_note_page.dart';
import 'package:submarine/screens/password_manager/password_manager_page.dart';
import 'package:submarine/screens/signin/signin_page.dart';
import 'package:submarine/screens/switch_account/switch_account_page.dart';
import 'package:submarine/screens/create_secret/create_secret_page.dart';
import 'package:submarine/screens/secret_detail/secret_detail_page.dart';
import 'package:submarine/screens/user_profile/user_profile_page.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_theme/system_theme.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nostr_widgets/l10n/app_localizations.dart'
    as nostr_widgets_l10n;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && GetPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }

  await SystemTheme.accentColor.load();

  final db = await getDatabase();
  final ndk = Ndk(
    NdkConfig(
      eventVerifier: Bip340EventVerifier(),
      cache: SembastCacheManager(db),
    ),
  );
  Get.put(ndk);

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
        if (kIsWeb) accentColor = Colors.teal;

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

        final app = ToastificationWrapper(
          child: GetMaterialApp(
            title: appTitle,
            theme: getTheme(),
            darkTheme: getTheme(Brightness.dark),
            themeMode: ThemeMode.system,
            localizationsDelegates: [
              nostr_widgets_l10n.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en'), Locale('fr')],
            getPages: [
              GetPage(name: AppRoutes.signIn, page: () => SigninPage()),
              GetPage(
                name: AppRoutes.switchAccount,
                page: () => SwitchAccountPage(),
              ),
              GetPage(
                name: AppRoutes.passwordManager,
                middlewares: [RouterMustBeLoggedInMiddleware()],
                page: () => PasswordManagerPage(),
              ),
              GetPage(
                name: AppRoutes.createSecret,
                middlewares: [RouterMustBeLoggedInMiddleware()],
                page: () => CreateSecretPage(),
              ),
              GetPage(
                name: AppRoutes.editSecret,
                middlewares: [RouterMustBeLoggedInMiddleware()],
                page: () => CreateSecretPage(),
              ),
              GetPage(
                name: AppRoutes.createNote,
                middlewares: [RouterMustBeLoggedInMiddleware()],
                page: () => CreateNotePage(),
              ),
              GetPage(
                name: AppRoutes.secretDetail,
                middlewares: [RouterMustBeLoggedInMiddleware()],
                page: () => SecretDetailPage(),
                transition: Transition.noTransition,
              ),
              GetPage(
                name: AppRoutes.userProfile,
                middlewares: [RouterMustBeLoggedInMiddleware()],
                page: () => UserProfilePage(),
              ),
            ],
          ),
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
