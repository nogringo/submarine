import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:submarine/lock/lock_page.dart';
import 'package:submarine/repository.dart';
import 'package:system_theme/system_theme.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemTheme.fallbackColor = const Color(0xFFfcc515);
  await SystemTheme.accentColor.load();

  await GetStorage.init();

  Get.put(Repository());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(builder: (context, accent) {
      ThemeData getThemeData(Brightness brightness) {
        return ThemeData.from(colorScheme: ColorScheme.fromSeed(
          seedColor: accent.accent,
          brightness: brightness,
        ));
      }

      return ToastificationWrapper(
        child: GetMaterialApp(
          theme: getThemeData(Brightness.light),
          darkTheme: getThemeData(Brightness.dark),
          home: const LockPage(),
        ),
      );
    });
  }
}
