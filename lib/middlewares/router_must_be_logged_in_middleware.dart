import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:submarine/app_routes.dart';
import 'package:submarine/repository.dart';

class RouterMustBeLoggedInMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Repository.to.ndk.accounts.isNotLoggedIn) {
      return const RouteSettings(name: AppRoutes.signIn);
    }

    return null;
  }
}
