
// ignore_for_file: unnecessary_null_comparison, use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/ui/widgets/flat_button.dart';



class AppPopupButton extends StatefulWidget {
  const AppPopupButton({super.key});

  @override
  _AppPopupButtonState createState() => _AppPopupButtonState();
}

class _AppPopupButtonState extends State<AppPopupButton> {
  double scanButtonSize = 0;
  double popupMarginBottom = 0;
  bool isScrolledUpEnough = false;
  bool firstTime = true;
  bool isSendButtonColorPrimary = true;
  Color popupColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Hero(
          tag: 'scanButton',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            height: scanButtonSize,
            width: scanButtonSize,
            decoration: BoxDecoration(
              color: popupColor,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.qr_code,
              size: scanButtonSize < 60 ? scanButtonSize / 1.8 : 33,
              color: StateContainer.of(context)!.curTheme.background,
            ),
          ),
        ),
        // Send Button
        GestureDetector(
          onVerticalDragStart: (StateContainer.of(context)?.wallet != null &&
                  StateContainer.of(context)!.wallet.accountBalance >
                      BigInt.zero)
              ? (value) {
                  setState(() {
                    popupColor = StateContainer.of(context)!.curTheme.primary;
                  });
                }
              : (value) {},
          onVerticalDragEnd: (StateContainer.of(context)?.wallet != null &&
                  StateContainer.of(context)!.wallet.accountBalance >
                      BigInt.zero)
              ? (value) {
                  isSendButtonColorPrimary = true;
                  firstTime = true;
                  if (isScrolledUpEnough) {
                    setState(() {
                      popupColor = Colors.white;
                    });
                    // Call your method here instead of scanAndHandlResult()
                  }
                  isScrolledUpEnough = false;
                  setState(() {
                    scanButtonSize = 0;
                  });
                }
              : (value) {},
          onVerticalDragUpdate: (StateContainer.of(context)?.wallet != null &&
                  StateContainer.of(context)!.wallet.accountBalance >
                      BigInt.zero)
              ? (dragUpdateDetails) {
                  if (dragUpdateDetails.localPosition.dy < -60) {
                    isScrolledUpEnough = true;
                    if (firstTime) {
                      // sl.get<HapticUtil>().success(); // Uncomment if HapticUtil is available
                    }
                    firstTime = false;
                    setState(() {
                      popupColor = StateContainer.of(context)!.curTheme.success;
                      isSendButtonColorPrimary = true;
                    });
                  } else {
                    isScrolledUpEnough = false;
                    popupColor = StateContainer.of(context)!.curTheme.primary;
                    isSendButtonColorPrimary = false;
                  }
                  // Swiping below the starting limit
                  if (dragUpdateDetails.localPosition.dy >= 0) {
                    setState(() {
                      scanButtonSize = 0;
                      popupMarginBottom = 0;
                    });
                  } else if (dragUpdateDetails.localPosition.dy > -60) {
                    setState(() {
                      scanButtonSize = dragUpdateDetails.localPosition.dy * -1;
                      popupMarginBottom = 5 + scanButtonSize / 3;
                    });
                  } else {
                    setState(() {
                      scanButtonSize = 60 +
                          ((dragUpdateDetails.localPosition.dy * -1) - 60) / 30;
                      popupMarginBottom = 5 + scanButtonSize / 3;
                    });
                  }
                }
              : (dragUpdateDetails) {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: [StateContainer.of(context)!.curTheme.boxShadowButton],
            ),
            height: 55,
            width: (MediaQuery.of(context).size.width - 42) / 2,
            margin: EdgeInsetsDirectional.only(
                start: 7, top: popupMarginBottom, end: 14.0),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0)),
              color: StateContainer.of(context)?.wallet != null &&
                      StateContainer.of(context)!.wallet.accountBalance >
                          BigInt.zero
                  ? isSendButtonColorPrimary
                      ? StateContainer.of(context)!.curTheme.primary
                      : StateContainer.of(context)!.curTheme.success
                  : StateContainer.of(context)!.curTheme.primary60,
              child: Text(
                AppLocalization.of(context)!.send,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              onPressed: () {
                if (StateContainer.of(context)?.wallet != null &&
                    StateContainer.of(context)!.wallet.accountBalance >
                        BigInt.zero) {
                  // Sheets.showAppHeightNineSheet(
                  //     context: context,
                  //     widget: SendSheet(
                  //         localCurrency:
                  //             StateContainer.of(context)?.curCurrency)); // Uncomment and replace with your method call
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

