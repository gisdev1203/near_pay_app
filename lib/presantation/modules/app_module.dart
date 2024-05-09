// ignore_for_file: depend_on_referenced_packages, override_on_non_overriding_member

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutterchain/flutterchain_lib.dart';
import 'package:flutterchain/flutterchain_lib/constants/chains/near_blockchain_network_urls.dart';
import 'package:flutterchain/flutterchain_lib/network/chains/near_rpc_client.dart';
import 'package:flutterchain/flutterchain_lib/repositories/wallet_repository.dart';
import 'package:flutterchain/flutterchain_lib/services/chains/near_blockchain_service.dart';


import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:near_pay_app/data/network/helper_network.dart';
import 'package:near_pay_app/main.dart';
import 'package:near_pay_app/presantation/modules/home/pages/core/create_wallet_page.dart';
import 'package:near_pay_app/presantation/modules/home/pages/core/crypto_actions_page.dart';
import 'package:near_pay_app/presantation/modules/home/pages/core/home_page.dart';
import 'package:near_pay_app/presantation/modules/home/services/helper_service.dart';
import 'package:near_pay_app/presantation/routes/routes.dart';
import 'package:near_pay_app/presantation/theme/app_theme.dart';

import 'package:provider/provider.dart';

class AppModule extends Module {
 

  @override
 void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<AppTheme>(create: (_) => AppTheme()),
        Provider<FlutterSecureStorage>(create: (_) => const FlutterSecureStorage()),
        
        Provider<NearNetworkClient>(create: (_) => NearNetworkClient(baseUrl: NearBlockChainNetworkUrls.listOfUrls.first, dio: Dio())),
        Provider<NearRpcClient>(create: (_) => NearRpcClient(networkClient: Modular.get<NearNetworkClient>())),
        
        Provider<NearHelperNetworkClient>(create: (_) => NearHelperNetworkClient(baseUrl: '', dio: Dio())),
        Provider<NearHelperService>(create: (_) => NearHelperService(Modular.get<NearHelperNetworkClient>())),
        // Repeat for Bitcoin-related services
        Provider<WalletRepository>(create: (_) => WalletRepository(secureStorage: Modular.get<FlutterSecureStorage>())),
        Provider<FlutterSecureStorage>(create: (_) => const FlutterSecureStorage()),
// Assuming you're using Dio for HTTP requests across your app
Provider<Dio>(create: (_) => Dio()), 
// Specific blockchain clients and services based on Dio
Provider<NearNetworkClient>(create: (_) => NearNetworkClient(baseUrl: NearBlockChainNetworkUrls.listOfUrls.first, dio: Dio())),
Provider<NearRpcClient>(create: (_) => NearRpcClient(networkClient: Modular.get<NearNetworkClient>())),
Provider<NearBlockChainService>(create: (_) => NearBlockChainService(jsVMService: Modular.get(), nearRpcClient: Modular.get<NearRpcClient>())),
// Assuming NearHelperNetworkClient and NearHelperService are correctly defined in your project
Provider<NearHelperNetworkClient>(create: (_) => NearHelperNetworkClient(baseUrl: '', dio: Dio())),
Provider<NearHelperService>(create: (_) => NearHelperService(Modular.get<NearHelperNetworkClient>())),
// WalletRepository and FlutterChainLibrary assuming these are based on the above or other provided services
Provider<WalletRepository>(create: (_) => WalletRepository(secureStorage: Modular.get<FlutterSecureStorage>())),
// If FlutterChainLibrary is your custom class, ensure its dependencies are correctly provided before usage
Provider<FlutterChainLibrary>(create: (_) => FlutterChainLibrary(Modular.get(), Modular.get())),
        
      ],
      child:  const MyApp(isAuthorized: null,),
    
     
    ),
  );
}
 
  

  @override
  final List<ModularRoute> route = [
    ChildRoute(Modular.initialRoute, child: (context) => const HomePage()),
    ChildRoute(Routes.home.startPage, child: (context) => const HomePage()),
    ChildRoute(Routes.home.actions, child: (context) => const CryptoActionsPage()),
    ChildRoute(Routes.home.login, child: (context) => const CreateWalletPage()),
    // Add more routes as needed
  ];
}