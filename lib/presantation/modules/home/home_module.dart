
// ignore_for_file: override_on_non_overriding_member

import 'package:flutter_modular/flutter_modular.dart';
import 'package:near_pay_app/presantation/modules/home/pages/core/create_wallet_page.dart';
import 'package:near_pay_app/presantation/modules/home/pages/core/crypto_actions_page.dart';
import 'package:near_pay_app/presantation/modules/home/pages/core/home_page.dart';
import 'package:near_pay_app/presantation/routes/routes.dart';

class HomeModule extends Module {
  @override
  final List<ModularRoute> route = [
    ChildRoute(Modular.initialRoute, child: (context) => const HomePage()),
    ChildRoute(Routes.home.startPage, child: (context) => const HomePage()),
    ChildRoute(Routes.home.actions, child: (context) => const CryptoActionsPage()),
    ChildRoute(Routes.home.login, child: (context) => const CreateWalletPage()),
    // Add more routes as needed
  ];
}
