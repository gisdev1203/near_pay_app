// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:near_pay_app/app_icons.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/presantation/ui/widgets/sheets.dart';
import 'package:near_pay_app/styles.dart';


class AppTransferCompleteSheet {
  String transferAmount;

  AppTransferCompleteSheet(this.transferAmount);

  mainBottomSheet(BuildContext context) {
    AppSheets.showAppHeightNineSheet(
        context: context,
        closeOnTap: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              minimum: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.035,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    //A container for the paragraph and seed
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Success tick (icon)
                          Container(
                            margin: const EdgeInsets.only(bottom: 30),
                            child: Icon(AppIcons.success,
                                size: 100,
                                color: StateContainer.of(context)!
                                    .curTheme
                                    .success),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.2,
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6),
                            child: Stack(
                              children: <Widget>[
                                Center(
                                  child: SvgPicture.asset(
                                    'assets/transferfunds_illustration_end_paperwalletonly.svg',
                                    color: StateContainer.of(context)!
                                        .curTheme
                                        .text45,
                                    width: MediaQuery.of(context).size.width
                                  ),
                                ),
                                Center(
                                  child: SvgPicture.asset(
                                    'assets/transferfunds_illustration_end_natriumwalletonly.svg',
                                    color: StateContainer.of(context)!
                                        .curTheme
                                        .success,
                                    width: MediaQuery.of(context).size.width
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                              alignment: const AlignmentDirectional(-1, 0),
                              margin: EdgeInsets.symmetric(
                                  horizontal: smallScreen(context) ? 35 : 60),
                              child: Text(
                                AppLocalization.of(context)!
                                    .transferComplete
                                    .replaceAll("%1", transferAmount),
                                style: AppStyles.textStyleParagraphSuccess(
                                    context),
                                textAlign: TextAlign.start,
                              )),
                          Container(
                              alignment: const AlignmentDirectional(-1, 0),
                              margin: EdgeInsets.symmetric(
                                  horizontal: smallScreen(context) ? 35 : 60),
                              child: Text(
                                AppLocalization.of(context)!.transferClose,
                                style: AppStyles.textStyleParagraph(context),
                                textAlign: TextAlign.start,
                              )),
                        ],
                      ),
                    ),

                    Row(
                      children: <Widget>[
                        AppButton.buildAppButton(
                          context,
                          AppButtonType.SUCCESS_OUTLINE,
                          AppLocalization.of(context)!.close.toUpperCase(),
                          Dimens.BUTTON_BOTTOM_DIMENS,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        }, color: null, barrier: null, onDisposed: null);
  }
}
