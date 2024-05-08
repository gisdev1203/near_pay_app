// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:logging/logging.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/core/models/wallet.dart';
import 'package:near_pay_app/data/network/account_service.dart';
import 'package:near_pay_app/data/network/model/response/account_balance_item.dart';
import 'package:near_pay_app/data/network/model/response/account_info_response.dart';
import 'package:near_pay_app/data/network/model/response/pending_response.dart';
import 'package:near_pay_app/data/network/model/response/pending_response_item.dart';
import 'package:near_pay_app/data/network/model/response/process_response.dart';

import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/bus/transfer_complete_event.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/presantation/ui/widgets/dialog.dart';
import 'package:near_pay_app/presantation/utils/caseconverter.dart';
import 'package:near_pay_app/presantation/utils/error_handler.dart';
import 'package:near_pay_app/presantation/utils/numberutil.dart';
import 'package:near_pay_app/service_locator.dart';
import 'package:near_pay_app/styles.dart';

import 'package:pointycastle/api.dart';


class AppTransferConfirmSheet extends StatefulWidget {
  final Map<String, AccountBalanceItem> privKeyBalanceMap;
  final Function errorCallback;

  const AppTransferConfirmSheet({super.key, required this.privKeyBalanceMap, required this.errorCallback});

  @override
  _AppTransferConfirmSheetState createState() =>
      _AppTransferConfirmSheetState();
}

class _AppTransferConfirmSheetState extends State<AppTransferConfirmSheet> {
  // Total amount there is to transfer
  late BigInt totalToTransfer;
  late String totalAsReadableAmount;
  // Need to be received by current account
  late PendingResponse accountPending;
  // Whether animation overlay is open
  late bool animationOpen;

  // StateContainer instead
  late StateContainerState state;

  @override
  void initState() {
    super.initState();
    totalToTransfer = BigInt.zero;
    totalAsReadableAmount = "";
    animationOpen = false;
    widget.privKeyBalanceMap
        .forEach((String account, AccountBalanceItem accountBalanceItem) {
      totalToTransfer += BigInt.parse(accountBalanceItem.balance) +
          BigInt.parse(accountBalanceItem.pending);
    });
    totalAsReadableAmount =
        NumberUtil.getRawAsUsableString(totalToTransfer.toString());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    state = StateContainer.of(context)!;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                    AppLocalization.of(context)!.transferHeader, context),
                style: AppStyles.textStyleHeader(context),
                textAlign: TextAlign.center,
                maxLines: 2,
                stepGranularity: 0.1,
              ),
            ),

            // A container for the paragraphs
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: smallScreen(context) ? 35 : 60),
                        child: Text(
                          AppLocalization.of(context)!
                              .transferConfirmInfo
                              .replaceAll("%1", totalAsReadableAmount),
                          style: AppStyles.textStyleParagraphPrimary(context),
                          textAlign: TextAlign.start,
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: smallScreen(context) ? 35 : 60),
                        child: Text(
                          AppLocalization.of(context)!.transferConfirmInfoSecond,
                          style: AppStyles.textStyleParagraph(context),
                          textAlign: TextAlign.start,
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: smallScreen(context) ? 35 : 60),
                        child: Text(
                          AppLocalization.of(context)!.transferConfirmInfoThird,
                          style: AppStyles.textStyleParagraph(context),
                          textAlign: TextAlign.start,
                        )),
                  ],
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Send Button
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        CaseChange.toUpperCase(
                            AppLocalization.of(context)!.confirm, context),
                        Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                      animationOpen = true;
                      Navigator.of(context).push(AnimationLoadingOverlay(
                          AnimationType.TRANSFER_TRANSFERRING,
                          StateContainer.of(context)!
                              .curTheme
                              .animationOverlayStrong,
                          StateContainer.of(context)!
                              .curTheme
                              .animationOverlayMedium, onPoppedCallback: () {
                        animationOpen = false;
                      }));
                      await processWallets();
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    // Scan QR Code Button
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY_OUTLINE,
                        AppLocalization.of(context)!.cancel.toUpperCase(),
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  

  Future<void> processWallets() async {
    BigInt totalTransferred = BigInt.zero;
    try {
      state.lockCallback();
      for (String account in widget.privKeyBalanceMap.keys) {
        AccountBalanceItem? balanceItem = widget.privKeyBalanceMap[account];
        // Get frontiers first
        AccountInfoResponse resp =
            await sl.get<AccountService>().getAccountInfo(account);
        if (!resp.unopened) {
          balanceItem?.frontier = resp.frontier;
        }
        // Receive pending blocks
        PendingResponse pr =
            await sl.get<AccountService>().getPending(account, 20, threshold: '');
        Map<String, PendingResponseItem> pendingBlocks = pr.blocks;
        for (String hash in pendingBlocks.keys) {
          PendingResponseItem? item = pendingBlocks[hash];
          if (balanceItem?.frontier != null) {
            ProcessResponse resp = await sl
                .get<AccountService>()
                .requestReceive(
                    AppWallet.defaultRepresentative,
                    balanceItem!.frontier,
                    item!.amount,
                    hash,
                    account,
                    balanceItem.privKey);
            balanceItem.frontier = resp.hash;
            totalTransferred += BigInt.parse(item.amount);
                    } else {
            ProcessResponse resp = await sl
                .get<AccountService>()
                .requestOpen(item!.amount, hash, account, balanceItem!.privKey, representative: '');
            balanceItem.frontier = resp.hash;
            totalTransferred += BigInt.parse(item.amount);
                    }
          // Hack that waits for blocks to be confirmed
          await Future.delayed(const Duration(milliseconds: 300));
        }
        // Process send from this account
        resp = await sl.get<AccountService>().getAccountInfo(account);
        totalTransferred += BigInt.parse(balanceItem!.balance);
            }
    } catch (e) {
      if (animationOpen) {
        Navigator.of(context).pop();
      }
      widget.errorCallback();
      sl.get<Logger>().e("Error processing wallet", error: e);
      return;
    } finally {
      state.unlockCallback();
    }
    try {
      state.lockCallback();
      // Receive all new blocks to our own account
      PendingResponse pr = await sl
          .get<AccountService>()
          .getPending(state.wallet.address, 20, includeActive: true, threshold: '');
      Map<String, PendingResponseItem> pendingBlocks = pr.blocks;
      for (String hash in pendingBlocks.keys) {
        PendingResponseItem? item = pendingBlocks[hash];
        ProcessResponse resp = await sl.get<AccountService>().requestReceive(
            state.wallet.representative,
            state.wallet.frontier,
            item!.amount,
            hash,
            state.wallet.address,
            (PrivateKey.fromSeed(state.selectedAccount.index)) as String);
        state.wallet.frontier = resp.hash;
                  }
      state.requestUpdate();
    } catch (e) {
      // Less-important error
      sl.get<Logger>().log("Error processing wallet" as Level , ErrorHandler());
    } finally {
      state.unlockCallback();
    }
    EventTaxiImpl.singleton()
        .fire(TransferCompleteEvent(amount: totalTransferred));
    if (animationOpen) {
      Navigator.of(context).pop();
    }
    Navigator.of(context).pop();
  }
}

