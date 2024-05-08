// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/app_icons.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/core/models/db/account.dart';
import 'package:near_pay_app/core/models/db/appdb.dart';

import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/bus/account_modified_event.dart';
import 'package:near_pay_app/presantation/ui/util/ui_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/app_text_field.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/presantation/ui/widgets/dialog.dart';
import 'package:near_pay_app/presantation/ui/widgets/flat_button.dart';
import 'package:near_pay_app/presantation/ui/widgets/sheets.dart';
import 'package:near_pay_app/presantation/ui/widgets/tap_outside_unfocus.dart';
import 'package:near_pay_app/presantation/utils/caseconverter.dart';
import 'package:near_pay_app/presantation/utils/numberutil.dart';

import 'package:near_pay_app/service_locator.dart';
import 'package:near_pay_app/styles.dart';



// Account Details Sheet
class AccountDetailsSheet {
  Account account;
  String originalName;
  TextEditingController _nameController;
  FocusNode _nameFocusNode;
  bool deleted;
  // Address copied or not
  bool _addressCopied;
  // Timer reference so we can cancel repeated events
  Timer _addressCopiedTimer;

  AccountDetailsSheet(this.account) {
    originalName = account.name;
    deleted = false;
  }

  Future<bool> _onWillPop() async {
    // Update name if changed and valid
    if (originalName != _nameController.text &&
        _nameController.text.trim().isNotEmpty &&
        !deleted) {
      sl.get<DBHelper>().changeAccountName(account, _nameController.text);
      account.name = _nameController.text;
      EventTaxiImpl.singleton().fire(AccountModifiedEvent(account: account));
    }
    return true;
  }

  mainBottomSheet(BuildContext context) {
    _addressCopied = false;
    _nameController = TextEditingController(text: account.name);
    _nameFocusNode = FocusNode();
    AppSheets.showAppHeightNineSheet(
        context: context,
        onDisposed: _onWillPop,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return PopScope(
                onWillPop: _onWillPop,
                child: TapOutsideUnfocus(
                    child: SafeArea(
                        minimum: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.035),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Trashcan Button
                                Container(
                                    width: 50,
                                    height: 50,
                                    margin: const EdgeInsetsDirectional.only(
                                        top: 10.0, start: 10.0),
                                    child: account.index == 0
                                        ? const SizedBox()
                                        : FlatButton(
                                            highlightColor:
                                                StateContainer.of(context)!
                                                    .curTheme
                                                    .text15,
                                            splashColor:
                                                StateContainer.of(context)!
                                                    .curTheme
                                                    .text15,
                                            onPressed: () {
                                              AppDialogs.showConfirmDialog(
                                                  context,
                                                  AppLocalization.of(context)!
                                                      .hideAccountHeader,
                                                  AppLocalization.of(context)!
                                                      .removeAccountText
                                                      .replaceAll(
                                                          "%1",
                                                          AppLocalization.of(
                                                                  context)!
                                                              .addAccount),
                                                  CaseChange.toUpperCase(
                                                      AppLocalization.of(
                                                              context)!
                                                          .yes,
                                                      context), () {
                                                // Remove account
                                                deleted = true;
                                                sl
                                                    .get<DBHelper>()
                                                    .deleteAccount(account)
                                                    .then((id) {
                                                  EventTaxiImpl.singleton()
                                                      .fire(
                                                          AccountModifiedEvent(
                                                              account: account,
                                                              deleted: true));
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                                  cancelText:
                                                      CaseChange.toUpperCase(
                                                          AppLocalization.of(
                                                                  context)!
                                                              .no,
                                                          context));
                                            },
                                            padding: const EdgeInsets.all(13.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0)),
                                            materialTapTargetSize:
                                                MaterialTapTargetSize.padded,
                                            child: Icon(AppIcons.trashcan,
                                                size: 24,
                                                color:
                                                    StateContainer.of(context)!
                                                        .curTheme
                                                        .text),
                                          )),
                                // The header of the sheet
                                Container(
                                  margin: const EdgeInsets.only(top: 25.0),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              140),
                                  child: Column(
                                    children: <Widget>[
                                      AutoSizeText(
                                        CaseChange.toUpperCase(
                                            AppLocalization.of(context)!.account,
                                            context),
                                        style:
                                            AppStyles.textStyleHeader(context),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        stepGranularity: 0.1,
                                      ),
                                    ],
                                  ),
                                ),
                                // Search Button
                                const SizedBox(height: 50, width: 50),
                              ],
                            ),
                            // Address Text
                            Container(
                              margin: const EdgeInsets.only(top: 10.0),
                              child: account.address != null
                                  ? UIUtil.threeLineAddressText(
                                      context, account.address,
                                      type: ThreeLineAddressTextType.PRIMARY60, contactName: '')
                                  : account.selected
                                      ? UIUtil.threeLineAddressText(
                                          context,
                                          StateContainer.of(context)!
                                              .wallet
                                              .address,
                                          type: ThreeLineAddressTextType
                                              .PRIMARY60, contactName: '')
                                      : const SizedBox(),
                            ),
                            // Balance Text
                            (account.balance != null || account.selected)
                                ? Container(
                                    margin: const EdgeInsets.only(top: 5.0),
                                    child: RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(
                                        text: '',
                                        children: [
                                          TextSpan(
                                            text: "(",
                                            style: TextStyle(
                                              color: StateContainer.of(context)!
                                                  .curTheme
                                                  .primary60,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w100,
                                              fontFamily: 'NunitoSans',
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                NumberUtil.getRawAsUsableString(
                                                    account.balance),
                                            style: TextStyle(
                                              color: StateContainer.of(context)!
                                                  .curTheme
                                                  .primary60,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'NunitoSans',
                                            ),
                                          ),
                                          TextSpan(
                                            text: " NANO)",
                                            style: TextStyle(
                                              color: StateContainer.of(context)!
                                                  .curTheme
                                                  .primary60,
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w100,
                                              fontFamily: 'NunitoSans',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(),

                            // The main container that holds Contact Name and Contact Address
                            Expanded(
                              child: KeyboardAvoider(
                                  duration: const Duration(milliseconds: 0),
                                  autoScroll: true,
                                  focusPadding: 40,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        AppTextField(
                                          topMargin: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.14,
                                          rightMargin: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.105,
                                          controller: _nameController,
                                          focusNode: _nameFocusNode,
                                          textInputAction: TextInputAction.done,
                                          autocorrect: false,
                                          keyboardType: TextInputType.text,
                                          inputFormatters: [
                                            LengthLimitingTextInputFormatter(
                                                15),
                                          ],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16.0,
                                            color: StateContainer.of(context)!
                                                .curTheme
                                                .primary,
                                            fontFamily: 'NunitoSans',
                                          ), cursorColor: null, leftMargin: null, hintText: '', prefixButton: null, suffixButton: null, fadePrefixOnCondition: null,
                                        ),
                                      ])),
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    AppButton.buildAppButton(
                                        context,
                                        // Share Address Button
                                        _addressCopied
                                            ? AppButtonType.SUCCESS
                                            : AppButtonType.PRIMARY,
                                        _addressCopied
                                            ? AppLocalization.of(context)!
                                                .addressCopied
                                            : AppLocalization.of(context)!
                                                .copyAddress,
                                        Dimens.BUTTON_TOP_DIMENS,
                                        onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: account.address));
                                      setState(() {
                                        // Set copied style
                                        _addressCopied = true;
                                      });
                                      _addressCopiedTimer.cancel();
                                                                            _addressCopiedTimer = Timer(
                                          const Duration(milliseconds: 800),
                                          () {
                                        setState(() {
                                          _addressCopied = false;
                                        });
                                      });
                                    }),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    // Close Button
                                    AppButton.buildAppButton(
                                        context,
                                        AppButtonType.PRIMARY_OUTLINE,
                                        AppLocalization.of(context)!.close,
                                        Dimens.BUTTON_BOTTOM_DIMENS,
                                        onPressed: () {
                                      Navigator.pop(context);
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ))));
          });
        }, color: null, barrier: null);
  }
}
