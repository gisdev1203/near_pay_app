// ignore_for_file: overridden_fields, constant_identifier_names, unnecessary_const, avoid_returning_null_for_void

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


abstract class BaseTheme {
  late Color primary;
  late Color primary60;
  late Color primary45;
 late Color primary30;
  late Color primary20;
  late Color primary15;
  late Color primary10;

  late Color success;
  late Color success60;
  late Color success30;
  late Color success15;
  late Color successDark;
  late Color successDark30;

  late Color background;
  late Color background40;
  late Color background00;

  late Color backgroundDark;
  late Color backgroundDark00;

  late Color backgroundDarkest;

  late Color text;
  late Color text60;
  late Color text45;
  late Color text30;
  late Color text20;
  late Color text15;
  late Color text10;
  late Color text05;
  late Color text03;

  late Color overlay20;
  late Color overlay30;
  late Color overlay50;
  late Color overlay70;
  late Color overlay80;
  late Color overlay85;
  late Color overlay90;

  late Color barrier;
  late Color barrierWeaker;
  late Color barrierWeakest;
  late Color barrierStronger;

  late Color animationOverlayMedium;
  late Color animationOverlayStrong;


  

  late Brightness brightness;
  late SystemUiOverlayStyle statusBar;

  late BoxShadow boxShadow;
  late BoxShadow boxShadowButton;

  // QR scanner theme
  late Overlay qrScanTheme;
  // App icon (iOS only)
  late AppIconEnum appIcon;
}

class NatriumTheme extends BaseTheme {
  static const brightBlue = Color(0xFFA3CDFF);

  static const green = Color(0xFF4AFFAE);

  static const greenDark = Color(0xFF18A264);

  static const blueishGreyDark = Color(0xFF1E2C3D);

  static const blueishGreyLight = Color(0xFF2A3A4D);

  static const blueishGreyDarkest = Color(0xFF1E2C3D);

  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF000000);

  @override
  Color primary = brightBlue;
  @override
  Color primary60 = brightBlue.withOpacity(0.6);
  @override
  Color primary45 = brightBlue.withOpacity(0.45);
  @override
  Color primary30 = brightBlue.withOpacity(0.3);
  @override
  Color primary20 = brightBlue.withOpacity(0.2);
  @override
  Color primary15 = brightBlue.withOpacity(0.15);
  @override
  Color primary10 = brightBlue.withOpacity(0.1);

  @override
  Color success = green;
  @override
  Color success60 = green.withOpacity(0.6);
  @override
  Color success30 = green.withOpacity(0.3);
  @override
  Color success15 = green.withOpacity(0.15);

  @override
  Color successDark = greenDark;
  @override
  Color successDark30 = greenDark.withOpacity(0.3);

  @override
  Color background = blueishGreyDark;
  @override
  Color background40 = blueishGreyDark.withOpacity(0.4);
  @override
  Color background00 = blueishGreyDark.withOpacity(0.0);

  @override
  Color backgroundDark = blueishGreyLight;
  @override
  Color backgroundDark00 = blueishGreyLight.withOpacity(0.0);

  @override
  Color backgroundDarkest = blueishGreyDarkest;

  @override
  Color text = white.withOpacity(0.9);
  @override
  Color text60 = white.withOpacity(0.6);
  @override
  Color text45 = white.withOpacity(0.45);
  @override
  Color text30 = white.withOpacity(0.3);
  @override
  Color text20 = white.withOpacity(0.2);
  @override
  Color text15 = white.withOpacity(0.15);
  @override
  Color text10 = white.withOpacity(0.1);
  @override
  Color text05 = white.withOpacity(0.05);
  @override
  Color text03 = white.withOpacity(0.03);

  @override
  Color overlay20 = black.withOpacity(0.2);
  @override
  Color overlay30 = black.withOpacity(0.3);
  @override
  Color overlay50 = black.withOpacity(0.5);
  @override
  Color overlay70 = black.withOpacity(0.7);
  @override
  Color overlay80 = black.withOpacity(0.8);
  @override
  Color overlay85 = black.withOpacity(0.85);
  @override
  Color overlay90 = black.withOpacity(0.9);

  @override
  Color barrier = black.withOpacity(0.7);
  @override
  Color barrierWeaker = black.withOpacity(0.4);
  @override
  Color barrierWeakest = black.withOpacity(0.3);
  @override
  Color barrierStronger = black.withOpacity(0.85);

  @override
  Color animationOverlayMedium = black.withOpacity(0.7);
  @override
  Color animationOverlayStrong = black.withOpacity(0.85);

  @override
  Brightness brightness = Brightness.dark;
  @override
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  @override
  BoxShadow boxShadow = const BoxShadow(color: Colors.transparent);
  @override
  BoxShadow boxShadowButton = const BoxShadow(color: Colors.transparent);

  @override
  Overlay qrScanTheme = Overlay.theme.NATRIUM;
  @override
  AppIconEnum appIcon = AppIconEnum.NATRIUM;
}

class TitaniumTheme extends BaseTheme {
  static const blueishGreen = Color(0xFF61C6AD);

  static const green = Color(0xFFB5ED88);

  static const greenDark = Color(0xFF5F893D);

  static const tealDark = Color(0xFF041920);

  static const tealLight = Color(0xFF052029);

  static const tealDarkest = Color(0xFF041920);

  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF000000);

  @override
  Color primary = blueishGreen;
  @override
  Color primary60 = blueishGreen.withOpacity(0.6);
  @override
  Color primary45 = blueishGreen.withOpacity(0.45);
  @override
  Color primary30 = blueishGreen.withOpacity(0.3);
  @override
  Color primary20 = blueishGreen.withOpacity(0.2);
  @override
  Color primary15 = blueishGreen.withOpacity(0.15);
  @override
  Color primary10 = blueishGreen.withOpacity(0.1);

  @override
  Color success = green;
  @override
  Color success60 = green.withOpacity(0.6);
  @override
  Color success30 = green.withOpacity(0.3);
  @override
  Color success15 = green.withOpacity(0.15);

  @override
  Color successDark = greenDark;
  @override
  Color successDark30 = greenDark.withOpacity(0.3);

  @override
  Color background = tealDark;
  @override
  Color background40 = tealDark.withOpacity(0.4);
  @override
  Color background00 = tealDark.withOpacity(0.0);

  @override
  Color backgroundDark = tealLight;
  @override
  Color backgroundDark00 = tealLight.withOpacity(0.0);

  @override
  Color backgroundDarkest = tealDarkest;

  @override
  Color text = white.withOpacity(0.9);
  @override
  Color text60 = white.withOpacity(0.6);
  @override
  Color text45 = white.withOpacity(0.45);
  @override
  Color text30 = white.withOpacity(0.3);
  @override
  Color text20 = white.withOpacity(0.2);
  @override
  Color text15 = white.withOpacity(0.15);
  @override
  Color text10 = white.withOpacity(0.1);
  @override
  Color text05 = white.withOpacity(0.05);
  @override
  Color text03 = white.withOpacity(0.03);

  @override
  Color overlay90 = black.withOpacity(0.9);
  @override
  Color overlay85 = black.withOpacity(0.85);
  @override
  Color overlay80 = black.withOpacity(0.8);
  @override
  Color overlay70 = black.withOpacity(0.7);
  @override
  Color overlay50 = black.withOpacity(0.5);
  @override
  Color overlay30 = black.withOpacity(0.3);
  @override
  Color overlay20 = black.withOpacity(0.2);

  @override
  Color barrier = black.withOpacity(0.7);
  @override
  Color barrierWeaker = black.withOpacity(0.4);
  @override
  Color barrierWeakest = black.withOpacity(0.3);
  @override
  Color barrierStronger = black.withOpacity(0.85);

  @override
  Color animationOverlayMedium = black.withOpacity(0.7);
  @override
  Color animationOverlayStrong = black.withOpacity(0.85);

  @override
  Brightness brightness = Brightness.dark;
  @override
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  @override
  BoxShadow boxShadow = const BoxShadow(color: Colors.transparent);
  @override
  BoxShadow boxShadowButton = const BoxShadow(color: Colors.transparent);

  @override
  Overlay qrScanTheme = Overlay.theme.TITANIUM;
  @override
  AppIconEnum appIcon = AppIconEnum.TITANIUM;
}

class IndiumTheme extends BaseTheme {
  static const deepBlue = Color(0xFF0050BB);

  static const green = Color(0xFF00A873);

  static const greenLight = Color(0xFF9EEDD4);

  static const white = Color(0xFFFFFFFF);

  static const whiteishDark = Color(0xFFE8F0FA);

  static const grey = Color(0xFF454868);

  static const black = Color(0xFF000000);

  static const darkDeepBlue = Color(0xFF0050BB);

  @override
  Color primary = deepBlue;
  @override
  Color primary60 = deepBlue.withOpacity(0.6);
  @override
  Color primary45 = deepBlue.withOpacity(0.45);
  @override
  Color primary30 = deepBlue.withOpacity(0.3);
  @override
  Color primary20 = deepBlue.withOpacity(0.2);
  @override
  Color primary15 = deepBlue.withOpacity(0.15);
  @override
  Color primary10 = deepBlue.withOpacity(0.1);

  @override
  Color success = green;
  @override
  Color success60 = green.withOpacity(0.6);
  @override
  Color success30 = green.withOpacity(0.3);
  @override
  Color success15 = green.withOpacity(0.15);

  @override
  Color successDark = greenLight;
  @override
  Color successDark30 = greenLight.withOpacity(0.3);

  @override
  Color background = white;
  @override
  Color background40 = white.withOpacity(0.4);
  @override
  Color background00 = white.withOpacity(0.0);

  @override
  Color backgroundDark = white;
  @override
  Color backgroundDark00 = white.withOpacity(0.0);

  @override
  Color backgroundDarkest = whiteishDark;

  @override
  Color text = grey.withOpacity(0.9);
  @override
  Color text60 = grey.withOpacity(0.6);
  @override
  Color text45 = grey.withOpacity(0.45);
  @override
  Color text30 = grey.withOpacity(0.3);
  @override
  Color text20 = grey.withOpacity(0.2);
  @override
  Color text15 = grey.withOpacity(0.15);
  @override
  Color text10 = grey.withOpacity(0.1);
  @override
  Color text05 = grey.withOpacity(0.05);
  @override
  Color text03 = grey.withOpacity(0.03);

  @override
  Color overlay90 = black.withOpacity(0.9);
  @override
  Color overlay85 = black.withOpacity(0.85);
  @override
  Color overlay80 = black.withOpacity(0.8);
  @override
  Color overlay70 = black.withOpacity(0.70);
  @override
  Color overlay50 = black.withOpacity(0.5);
  @override
  Color overlay30 = black.withOpacity(0.3);
  @override
  Color overlay20 = black.withOpacity(0.2);

  @override
  Color barrier = black.withOpacity(0.7);
  @override
  Color barrierWeaker = black.withOpacity(0.4);
  @override
  Color barrierWeakest = black.withOpacity(0.3);
  @override
  Color barrierStronger = black.withOpacity(0.85);

  @override
  Color animationOverlayMedium = white.withOpacity(0.7);
  @override
  Color animationOverlayStrong = white.withOpacity(0.85);

  @override
  Brightness brightness = Brightness.light;
  @override
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent);

  @override
  BoxShadow boxShadow = BoxShadow(
      color: darkDeepBlue.withOpacity(0.1),
      offset: const Offset(0, 5),
      blurRadius: 15);
  @override
  BoxShadow boxShadowButton = BoxShadow(
      color: darkDeepBlue.withOpacity(0.2),
      offset: const Offset(0, 5),
      blurRadius: 15);

  @override
  Overlay qrScanTheme = Overlay.theme.INDIUM;
  @override
  AppIconEnum appIcon = AppIconEnum.INDIUM;
}

class NeptuniumTheme extends BaseTheme {
  static const blue = Color(0xFF4A90E2);

  static const orange = Color(0xFFF9AE42);

  static const orangeDark = Color(0xFF9C671E);

  static const blueDark = Color(0xFF000034);

  static const blueLightish = Color(0xFF080840);

  static const blueDarkest = Color(0xFF000034);

  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF000000);

  @override
  Color primary = blue;
  @override
  Color primary60 = blue.withOpacity(0.6);
  @override
  Color primary45 = blue.withOpacity(0.45);
  @override
  Color primary30 = blue.withOpacity(0.3);
  @override
  Color primary20 = blue.withOpacity(0.2);
  @override
  Color primary15 = blue.withOpacity(0.15);
  @override
  Color primary10 = blue.withOpacity(0.1);

  @override
  Color success = orange;
  @override
  Color success60 = orange.withOpacity(0.6);
  @override
  Color success30 = orange.withOpacity(0.3);
  @override
  Color success15 = orange.withOpacity(0.15);

  @override
  Color successDark = orangeDark;
  @override
  Color successDark30 = orangeDark.withOpacity(0.3);

  @override
  Color background = blueDark;
  @override
  Color background40 = blueDark.withOpacity(0.4);
  @override
  Color background00 = blueDark.withOpacity(0.0);

  @override
  Color backgroundDark = blueLightish;
  @override
  Color backgroundDark00 = blueLightish.withOpacity(0.0);

  @override
  Color backgroundDarkest = blueDarkest;

  @override
  Color text = white.withOpacity(0.9);
  @override
  Color text60 = white.withOpacity(0.6);
  @override
  Color text45 = white.withOpacity(0.45);
  @override
  Color text30 = white.withOpacity(0.3);
  @override
  Color text20 = white.withOpacity(0.2);
  @override
  Color text15 = white.withOpacity(0.15);
  @override
  Color text10 = white.withOpacity(0.1);
  @override
  Color text05 = white.withOpacity(0.05);
  @override
  Color text03 = white.withOpacity(0.03);

  @override
  Color overlay90 = black.withOpacity(0.9);
  @override
  Color overlay85 = black.withOpacity(0.85);
  @override
  Color overlay80 = black.withOpacity(0.8);
  @override
  Color overlay70 = black.withOpacity(0.7);
  @override
  Color overlay50 = black.withOpacity(0.5);
  @override
  Color overlay30 = black.withOpacity(0.3);
  @override
  Color overlay20 = black.withOpacity(0.2);

  @override
  Color barrier = black.withOpacity(0.75);
  @override
  Color barrierWeaker = black.withOpacity(0.45);
  @override
  Color barrierWeakest = black.withOpacity(0.35);
  @override
  Color barrierStronger = black.withOpacity(0.9);

  @override
  Color animationOverlayMedium = black.withOpacity(0.75);
  @override
  Color animationOverlayStrong = black.withOpacity(0.9);

  @override
  Brightness brightness = Brightness.dark;
  @override
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  @override
  BoxShadow boxShadow = const BoxShadow(color: Colors.transparent);
  @override
  BoxShadow boxShadowButton = const BoxShadow(color: Colors.transparent);

  @override
  Overlay qrScanTheme = Overlay.Theme.NEPTUNIUM;
  @override
  AppIconEnum appIcon = AppIconEnum.NEPTUNIUM;
}

class ThoriumTheme extends BaseTheme {
  static const teal = Color(0xFF75F3FF);

  static const orange = Color(0xFFFFBA59);

  static const orangeDark = Color(0xFFBF8026);

  static const purpleDark = Color(0xFF200A40);

  static const purpleLight = Color(0xFF2A1052);

  static const purpleDarkest = Color(0xFF200A40);

  static const white = Color(0xFFFFFFFF);

  static const black = Color(0xFF000000);

  @override
  Color primary = teal;
  @override
  Color primary60 = teal.withOpacity(0.6);
  @override
  Color primary45 = teal.withOpacity(0.45);
  @override
  Color primary30 = teal.withOpacity(0.3);
  @override
  Color primary20 = teal.withOpacity(0.2);
  @override
  Color primary15 = teal.withOpacity(0.15);
  @override
  Color primary10 = teal.withOpacity(0.1);

  @override
  Color success = orange;
  @override
  Color success60 = orange.withOpacity(0.6);
  @override
  Color success30 = orange.withOpacity(0.3);
  @override
  Color success15 = orange.withOpacity(0.15);

  @override
  Color successDark = orangeDark;
  @override
  Color successDark30 = orangeDark.withOpacity(0.3);

  @override
  Color background = purpleDark;
  @override
  Color background40 = purpleDark.withOpacity(0.4);
  @override
  Color background00 = purpleDark.withOpacity(0.0);

  @override
  Color backgroundDark = purpleLight;
  @override
  Color backgroundDark00 = purpleLight.withOpacity(0.0);

  @override
  Color backgroundDarkest = purpleDarkest;

  @override
  Color text = white.withOpacity(0.9);
  @override
  Color text60 = white.withOpacity(0.6);
  @override
  Color text45 = white.withOpacity(0.45);
  @override
  Color text30 = white.withOpacity(0.3);
  @override
  Color text20 = white.withOpacity(0.2);
  @override
  Color text15 = white.withOpacity(0.15);
  @override
  Color text10 = white.withOpacity(0.1);
  @override
  Color text05 = white.withOpacity(0.05);
  @override
  Color text03 = white.withOpacity(0.03);

  @override
  Color overlay90 = black.withOpacity(0.9);
  @override
  Color overlay85 = black.withOpacity(0.85);
  @override
  Color overlay80 = black.withOpacity(0.8);
  @override
  Color overlay70 = black.withOpacity(0.7);
  @override
  Color overlay50 = black.withOpacity(0.5);
  @override
  Color overlay30 = black.withOpacity(0.3);
  @override
  Color overlay20 = black.withOpacity(0.2);

  @override
  Color barrier = black.withOpacity(0.7);
  @override
  Color barrierWeaker = black.withOpacity(0.4);
  @override
  Color barrierWeakest = black.withOpacity(0.3);
  @override
  Color barrierStronger = black.withOpacity(0.85);

  @override
  Color animationOverlayMedium = black.withOpacity(0.7);
  @override
  Color animationOverlayStrong = black.withOpacity(0.85);

  @override
  Brightness brightness = Brightness.dark;
  @override
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  @override
  BoxShadow boxShadow = const BoxShadow(color: Colors.transparent);
  @override
  BoxShadow boxShadowButton = const BoxShadow(color: Colors.transparent);

  @override
  Overlay qrScanTheme = Overlay.Theme.THORIUM;
  @override
  AppIconEnum appIcon = AppIconEnum.THORIUM;
}

class CarbonTheme extends BaseTheme {
  static const brightBlue = Color(0xFF99C1F0);

  static const green = Color(0xFF41E099);

  static const greenDark = Color(0xFF148A55);

  static const white = Color(0xFFFFFFFF);
  static const whiteish = Color(0xFFE9E9F2);

  static const black = Color(0xFF000000);
  static const blackBlueish = Color(0xFF0D1014);
  static const blackLighter = Color(0xFF0E0F0F);

  @override
  Color primary = brightBlue;
  @override
  Color primary60 = brightBlue.withOpacity(0.6);
  @override
  Color primary45 = brightBlue.withOpacity(0.45);
  @override
  Color primary30 = brightBlue.withOpacity(0.3);
  @override
  Color primary20 = brightBlue.withOpacity(0.2);
  @override
  Color primary15 = brightBlue.withOpacity(0.15);
  @override
  Color primary10 = brightBlue.withOpacity(0.1);

  @override
  Color success = green;
  @override
  Color success60 = green.withOpacity(0.6);
  @override
  Color success30 = green.withOpacity(0.3);
  @override
  Color success15 = green.withOpacity(0.15);

  @override
  Color successDark = greenDark;
  @override
  Color successDark30 = greenDark.withOpacity(0.3);

  @override
  Color background = black;
  @override
  Color background40 = black.withOpacity(0.4);
  @override
  Color background00 = black.withOpacity(0.0);

  @override
  Color backgroundDark = black;
  @override
  Color backgroundDark00 = black.withOpacity(0.0);

  @override
  Color backgroundDarkest = blackLighter;

  @override
  Color text = whiteish.withOpacity(0.9);
  @override
  Color text60 = whiteish.withOpacity(0.6);
  @override
  Color text45 = whiteish.withOpacity(0.45);
  @override
  Color text30 = whiteish.withOpacity(0.3);
  @override
  Color text20 = whiteish.withOpacity(0.2);
  @override
  Color text15 = whiteish.withOpacity(0.15);
  @override
  Color text10 = whiteish.withOpacity(0.1);
  @override
  Color text05 = whiteish.withOpacity(0.05);
  @override
  Color text03 = whiteish.withOpacity(0.03);

  @override
  Color overlay90 = blackLighter.withOpacity(0.9);
  @override
  Color overlay85 = blackLighter.withOpacity(0.85);
  @override
  Color overlay80 = blackLighter.withOpacity(0.8);
  @override
  Color overlay70 = blackLighter.withOpacity(0.7);
  @override
  Color overlay50 = blackLighter.withOpacity(0.5);
  @override
  Color overlay30 = blackLighter.withOpacity(0.3);
  @override
  Color overlay20 = blackLighter.withOpacity(0.2);

  @override
  Color barrier = blackBlueish.withOpacity(0.8);
  @override
  Color barrierWeaker = blackBlueish.withOpacity(0.7);
  @override
  Color barrierWeakest = blackBlueish.withOpacity(0.35);
  @override
  Color barrierStronger = blackBlueish.withOpacity(0.9);

  @override
  Color animationOverlayMedium = blackBlueish.withOpacity(0.8);
  @override
  Color animationOverlayStrong = blackBlueish.withOpacity(0.9);

  @override
  Brightness brightness = Brightness.dark;
  @override
  SystemUiOverlayStyle statusBar =
      SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);

  @override
  BoxShadow boxShadow = BoxShadow(
    color: white.withOpacity(0.14),
    offset: const Offset(0, 0),
    blurRadius: 0,
    spreadRadius: 1,
  );
  @override
  BoxShadow boxShadowButton = BoxShadow(
    color: brightBlue.withOpacity(0.24),
    offset: const Offset(0, 0),
    blurRadius: 0,
    spreadRadius: 0,
  );

  @override
  Overlay qrScanTheme = Overlay.Theme.CARBON;
  @override
  AppIconEnum appIcon = AppIconEnum.CARBON;
}

enum AppIconEnum { NATRIUM, TITANIUM, INDIUM, NEPTUNIUM, THORIUM, CARBON }

class AppIcon {
  static const _channel = const MethodChannel('fappchannel');

  static Future<void> setAppIcon(AppIconEnum iconToChange) async {
    if (!Platform.isIOS) {
      return null;
    }
    String iconStr = "natrium";
    switch (iconToChange) {
      case AppIconEnum.THORIUM:
        iconStr = "thorium";
        break;
      case AppIconEnum.NEPTUNIUM:
        iconStr = "neptunium";
        break;
      case AppIconEnum.INDIUM:
        iconStr = "indium";
        break;
      case AppIconEnum.TITANIUM:
        iconStr = "titanium";
        break;
      case AppIconEnum.CARBON:
        iconStr = "carbon";
        break;
      case AppIconEnum.NATRIUM:
      default:
        iconStr = "natrium";
        break;
    }
    final Map<String, dynamic> params = <String, dynamic>{
      'icon': iconStr,
    };
    return await _channel.invokeMethod('changeIcon', params);
  }
}
