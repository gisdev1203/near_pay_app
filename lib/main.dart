// ignore_for_file: use_function_type_syntax_for_parameters

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:near_pay_app/core/l10n/app_localizations.dart';
import 'package:near_pay_app/presantation/modules/home/pages/core/home_page.dart';
import 'package:near_pay_app/presantation/modules/home/pages/core/login_page.dart';
import 'package:near_pay_app/presantation/services/core/lib_initialization_service.dart';
import 'package:near_pay_app/presantation/services/user_service.dart';

import 'package:provider/provider.dart';








void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFlutterChainLib(); // I changed runedzoneguard to see logg errors
  final isAuthorized = await checkIfUserAuthorized(); 

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(MyApp(isAuthorized: isAuthorized));
}

class MyApp extends StatelessWidget {
  final bool? isAuthorized;
  
  const MyApp({super.key, required this.isAuthorized});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserService(isAuthorized as Dio)), 
        
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690), 
        builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Your App Title',
          localizationsDelegates: const [
            AppLocalizations.delegate, 
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: isAuthorized == true ? const HomePage() :  const LoginPage(), 
          
        ),
      ),
    );
  }
}
