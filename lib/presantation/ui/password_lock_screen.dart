// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:event_taxi/event_taxi.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:near_pay_app/app_icons.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/bus/fcm_update_event.dart';
import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/models/vault.dart';
import 'package:near_pay_app/modules/home/services/helper_service.dart';
import 'package:near_pay_app/service_locator.dart';
import 'package:near_pay_app/styles.dart';
import 'package:near_pay_app/ui/widgets/app_text_field.dart';
import 'package:near_pay_app/ui/widgets/buttons.dart';
import 'package:near_pay_app/ui/widgets/dialog.dart';
import 'package:near_pay_app/ui/widgets/flat_button.dart';
import 'package:near_pay_app/ui/widgets/tap_outside_unfocus.dart';
import 'package:near_pay_app/utils/caseconverter.dart';
import 'package:near_pay_app/utils/encrypt.dart';
import 'package:near_pay_app/utils/sharedprefsutil.dart';


class AppPasswordLockScreen extends StatefulWidget {
  const AppPasswordLockScreen({super.key});

  @override
  _AppPasswordLockScreenState createState() => _AppPasswordLockScreenState();
}

class _AppPasswordLockScreenState extends State<AppPasswordLockScreen> {
  late FocusNode enterPasswordFocusNode;
  late TextEditingController enterPasswordController;

  late String passwordError;

  @override
  void initState() {
    super.initState();
    enterPasswordFocusNode = FocusNode();
    enterPasswordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: TapOutsideUnfocus(
            child: Container(
          color: StateContainer.of(context)!.curTheme.backgroundDark,
          width: double.infinity,
          child: SafeArea(
            minimum: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.035,
            ),
            child: Column(
              children: <Widget>[
                // Logout button
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 16, top: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        onPressed: () {
                          AppDialogs.showConfirmDialog(
                              context,
                              CaseChange.toUpperCase(
                                  AppLocalization.of(context)!.warning, context),
                              AppLocalization.of(context)?.logoutDetail,
                              AppLocalization.of(context)
                                  ?.logoutAction
                                  .toUpperCase(), () {
                            // Show another confirm dialog
                            AppDialogs.showConfirmDialog(
                                context,
                                AppLocalization.of(context)?.logoutAreYouSure,
                                AppLocalization.of(context)?.logoutReassurance,
                                CaseChange.toUpperCase(
                                    AppLocalization.of(context)!.yes, context),
                                () {
                              // Unsubscribe from notifications
                              sl
                                  .get<SharedPrefsUtil>()
                                  .setNotificationsOn(false)
                                  .then((_) {
                                FirebaseMessaging.instance
                                    .getToken()
                                    .then((fcmToken) {
                                  EventTaxiImpl.singleton()
                                      .fire(FcmUpdateEvent(token: fcmToken));
                                  // Delete all data
                                  sl.get<Vault>().deleteAll().then((_) {
                                    sl
                                        .get<SharedPrefsUtil>()
                                        .deleteAll()
                                        .then((result) {
                                      StateContainer.of(context)?.logOut();
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil('/',
                                              (Route<dynamic> route) => false);
                                    });
                                  });
                                });
                              });
                            });
                          });
                        },
                        highlightColor:
                            StateContainer.of(context)!.curTheme.text15,
                        splashColor: StateContainer.of(context)!.curTheme.text30,
                        padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 4),
                        child: Row(
                          children: <Widget>[
                            Icon(AppIcons.logout,
                                size: 16,
                                color:
                                    StateContainer.of(context)!.curTheme.text),
                            Container(
                              margin: const EdgeInsetsDirectional.only(start: 4),
                              child: Text(AppLocalization.of(context)!.logout,
                                  style: AppStyles.textStyleLogoutButton(
                                      context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.1),
                      child: Icon(
                        AppIcons.lock,
                        size: 80,
                        color: StateContainer.of(context)!.curTheme.primary,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Text(
                        CaseChange.toUpperCase(
                            AppLocalization.of(context)!.locked, context),
                        style: AppStyles.textStyleHeaderColored(context),
                      ),
                    ),
                    Expanded(
                        child: KeyboardAvoidingView(
                            duration: const Duration(milliseconds: 0),
                            autoScroll: true,
                            focusPadding: 40,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  // Enter your password Text Field
                                  AppTextField(
                                    topMargin: 30,
                                    padding: const EdgeInsetsDirectional.only(
                                        start: 16, end: 16),
                                    focusNode: enterPasswordFocusNode,
                                    controller: enterPasswordController,
                                    textInputAction: TextInputAction.go,
                                    autofocus: true,
                                    onChanged: (String newText) {
                                      setState(() {
                                        passwordError = 'You must enter a password';
                                      });
                                                                        },
                                    onSubmitted: (value) async {
                                      FocusScope.of(context).unfocus();
                                      await validateAndDecrypt();
                                    },
                                    hintText: AppLocalization.of(context)
                                        !.enterPasswordHint,
                                    keyboardType: TextInputType.text,
                                    obscureText: true,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.0,
                                      color: StateContainer.of(context)!
                                          .curTheme
                                          .primary,
                                      fontFamily: 'NunitoSans',
                                    ),
                                  ),
                                  // Error Container
                                  Container(
                                    alignment: const AlignmentDirectional(0, 0),
                                    margin: const EdgeInsets.only(top: 3),
                                    child: Text(
                                        passwordError,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          color: StateContainer.of(context)
                                              ?.curTheme
                                              .primary,
                                          fontFamily: 'NunitoSans',
                                          fontWeight: FontWeight.w600,
                                        )),
                                  ),
                                ])))
                  ],
                )),
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        AppLocalization.of(context)!.unlock,
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () async {
                      await validateAndDecrypt();
                    }),
                  ],
                )
              ],
            ),
          ),
        )));
  }

  Future<void> validateAndDecrypt() async {
    try {
    String decryptedSeed = NearHelperService.byteToHex(NearHelperService.decrypt(
      await sl.get<Vault>().getSeed(), enterPasswordController.text));

  // Session key ile şifrele
  List<int> sessionKey = (await sl.get<Vault>().getSessionKey()) as List<int>;
  String encryptedSeedHex = '';
  if (decryptedSeed.isNotEmpty) {
    Salsa20Encryptor encryptor = Salsa20Encryptor(bytesToHex(sessionKey), "your_iv_here");
    encryptedSeedHex = encryptor.encrypt(decryptedSeed);
  }

  // Şifreli veriyi state'e kaydet
  StateContainer.of(context)?.setEncryptedSecret(encryptedSeedHex);
      _goHome();
    } catch (e) {
      if (mounted) {
        setState(() {
          passwordError = AppLocalization.of(context)!.invalidPassword;
        });
      }
    }
  }

  Future<void> _goHome() async {
    if (StateContainer.of(context)?.wallet != null) {
      StateContainer.of(context)?.reconnect();
    } else {
      await NearHelperService.byteToHex(NearHelperService.decrypt(
          await sl.get<Vault>().getSeed()
      ))
          .loginAccount(await StateContainer.of(context)?.getSeed(), context);
    }
    StateContainer.of(context)?.requestUpdate();
    PriceConversion conversion =
        await sl.get<SharedPrefsUtil>().getPriceConversion();
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/home_transition', (Route<dynamic> route) => false,
        arguments: conversion);
  }
}
