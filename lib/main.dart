import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:submarine/database.dart';
import 'package:submarine/lock/lock_page.dart';
import 'package:submarine/repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:submarine/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(AppDatabase());

  await GetStorage.init();

  Get.put(Repository());

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        Repository.to.onUserActivity();
      },
      child: GetMaterialApp(
        theme: ThemeData.from(colorScheme: MaterialTheme.lightScheme()),
        darkTheme: ThemeData.from(colorScheme: MaterialTheme.darkScheme()),
        getPages: [
          GetPage(
            name: "/",
            page: () => const LockPage(),
          ),
        ],
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
