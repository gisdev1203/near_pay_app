// ignore_for_file: library_private_types_in_public_api

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:near_pay_app/app_icons.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/ui/widgets/app_text_field.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/presantation/ui/widgets/tap_outside_unfocus.dart';
import 'package:near_pay_app/presantation/utils/caseconverter.dart';
import 'package:near_pay_app/presantation/utils/user_data_util.dart';
import 'package:near_pay_app/styles.dart';



class TransferManualEntrySheet extends StatefulWidget {
  final Function validSeedCallback;

  const TransferManualEntrySheet({super.key, required this.validSeedCallback});

  @override
  _TransferManualEntrySheetState createState() => _TransferManualEntrySheetState();
}

class _TransferManualEntrySheetState extends State<TransferManualEntrySheet> {
  late FocusNode _seedInputFocusNode;
  late TextEditingController _seedInputController;

  // State constants
  late bool seedIsValid;
  late bool hasError;

  @override
  void initState() {
    super.initState();
    _seedInputController = TextEditingController();
    _seedInputFocusNode = FocusNode();
    seedIsValid = false;
    hasError = false;
  }

  @override
  Widget build(BuildContext context) {
    return TapOutsideUnfocus(
      child: SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            //A container for the header
            Container(
              margin: const EdgeInsets.only(top: 30.0, left: 70, right: 70),
              child: AutoSizeText(
                CaseChange.toUpperCase(
                    AppLocalization.of(context)!.transferHeader,
                    context),
                style: AppStyles.textStyleHeader(context),
                textAlign: TextAlign.center,
                maxLines: 2,
                stepGranularity: 0.1,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // The paragraph
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal:
                              smallScreen(context) ? 50 : 60,
                          vertical: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalization.of(context)!
                            .transferManualHint,
                        style:
                            AppStyles.textStyleParagraph(context),
                        textAlign: TextAlign.start,
                      ),
                    ),
                    // The container for the seed
                    Expanded(
                      child: KeyboardAvoider(
                        duration: const Duration(milliseconds: 0),
                        autoScroll: true,
                        focusPadding: 40,
                        child: Column(
                          children: <Widget>[
                            AppTextField(
                              focusNode: _seedInputFocusNode,
                              controller: _seedInputController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(64),
                              ],
                              textInputAction: TextInputAction.done,
                              maxLines: null,
                              autocorrect: false,
                              suffixButton: TextFieldButton(
                                icon: AppIcons.paste,
                                onPressed: () async {
                                  String? data = await UserDataUtil.getClipboardText(DataType.SEED);
                                  if (mounted) {
                                    _seedInputController.text = data!;
                                    setState(() {
                                      seedIsValid = true;
                                    });                                            
                                  }
                                                                },
                              ),
                              fadeSuffixOnCondition: true,
                              suffixShowFirstCondition: !NanoSeeds.isValidSeed(_seedInputController.text),
                              keyboardType: TextInputType.text,
                              style: seedIsValid ? AppStyles.textStyleSeed(context) : AppStyles.textStyleSeedGray(context),
                              onChanged: (text) {
                                // Always reset the error message to be less annoying
                                setState(() {
                                  hasError = false;
                                });
                                // If valid seed, clear focus/close keyboard
                                if (NanoSeeds.isValidSeed(text) && mounted) {
                                  _seedInputFocusNode.unfocus();
                                  setState(() {
                                    seedIsValid = true;
                                  });
                                } else if (mounted) {
                                  setState(() {
                                    seedIsValid = false;
                                  });
                                }
                              },
                            ),
                            // "Invalid Seed" text that appears if the input is invalid
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              child: Text(
                                  AppLocalization.of(context)!.seedInvalid,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: hasError ? StateContainer.of(context)!.curTheme.primary : Colors.transparent,
                                    fontFamily: 'NunitoSans',
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ]
                        )
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Row(
              children: <Widget>[
                AppButton.buildAppButton(
                  context,
                  AppButtonType.PRIMARY,
                  AppLocalization.of(context)!.transfer,
                  Dimens.BUTTON_TOP_DIMENS,
                  onPressed: () {
                    if (NanoSeeds.isValidSeed(_seedInputController.text)) {
                      widget.validSeedCallback(_seedInputController.text);
                    } else if (mounted) {
                      setState(() {
                        hasError = true;
                      });
                    }
                  },
                ),
              ],
            ),

            Row(
              children: <Widget>[
                AppButton.buildAppButton(
                  context,
                  AppButtonType.PRIMARY_OUTLINE,
                  AppLocalization.of(context)!.cancel,
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
    ));
  }
}
