// ignore_for_file: library_private_types_in_public_api, constant_identifier_names

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:logging/logging.dart';
import 'package:near_pay_app/app_icons.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/core/models/db/account.dart';
import 'package:near_pay_app/core/models/db/appdb.dart';
import 'package:near_pay_app/data/network/model/response/accounts_balances_response.dart';

import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/bus/account_changed_event.dart';
import 'package:near_pay_app/presantation/bus/account_modified_event.dart';
import 'package:near_pay_app/presantation/ui/accounts/accountdetails_sheet.dart';
import 'package:near_pay_app/presantation/ui/util/ui_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/presantation/ui/widgets/dialog.dart';
import 'package:near_pay_app/presantation/ui/widgets/flat_button.dart';
import 'package:near_pay_app/presantation/ui/widgets/list_slidable.dart';
import 'package:near_pay_app/presantation/ui/widgets/sheets.dart';
import 'package:near_pay_app/presantation/utils/caseconverter.dart';
import 'package:near_pay_app/presantation/utils/numberutil.dart';

import 'package:near_pay_app/service_locator.dart';
import 'package:near_pay_app/styles.dart';

import '../../../data/network/account_service.dart';


class AppAccountsSheet {
  List<Account> accounts;

  AppAccountsSheet(this.accounts);

  mainBottomSheet(BuildContext context) {
    AppSheets.showAppHeightNineSheet(
        context: context,
        builder: (BuildContext context) {
          return AppAccountsWidget(accounts: accounts, key: null,);
        }, color: null, barrier: null, onDisposed: null);
  }
}

class AppAccountsWidget extends StatefulWidget {
  final List<Account> accounts;

  const AppAccountsWidget({required Key key, required this.accounts}) : super(key: key);

  @override
  _AppAccountsWidgetState createState() => _AppAccountsWidgetState();
}

class _AppAccountsWidgetState extends State<AppAccountsWidget> {
  static const int MAX_ACCOUNTS = 50;
  final GlobalKey expandedKey = GlobalKey();

  late bool _addingAccount;
  final ScrollController _scrollController = ScrollController();

  late StreamSubscription<AccountModifiedEvent> _accountModifiedSub;
  late bool _accountIsChanging;


  @override
  void initState() {
    super.initState();
    _registerBus();
    _addingAccount = false;
    _accountIsChanging = false;
  }

  @override
  void dispose() {
    _destroyBus();
    super.dispose();
  }

  Future<void> _handleAccountsBalancesResponse(
      AccountsBalancesResponse resp) async {
    // Handle balances event
    for (var account in widget.accounts) {
      resp.balances.forEach((address, balance) {
        address = address.replaceAll("xrb_", "nano_");
        String combinedBalance = (BigInt.tryParse(balance.balance) +
                BigInt.tryParse(balance.pending))
            .toString();
        if (account.address == address && combinedBalance != account.balance) {
          sl.get<DBHelper>().updateAccountBalance(account, combinedBalance);
          setState(() {
            account.balance = combinedBalance;
          });
        }
      });
    }
  }

  void _registerBus() {
    _accountModifiedSub = EventTaxiImpl.singleton()
        .registerTo<AccountModifiedEvent>()
        .listen((event) {
      if (event.deleted) {
        if (event.account.selected) {
          Future.delayed(const Duration(milliseconds: 50), () {
            setState(() {
              widget.accounts
                  .where((a) =>
                      a.index ==
                      StateContainer.of(context)!.selectedAccount.index)
                  .forEach((account) {
                account.selected = true;
              });
            });
          });
        }
        setState(() {
          widget.accounts.removeWhere((a) => a.index == event.account.index);
        });
      } else {
        // Name change
        setState(() {
          widget.accounts.removeWhere((a) => a.index == event.account.index);
          widget.accounts.add(event.account);
          widget.accounts.sort((a, b) => a.index.compareTo(b.index));
        });
      }
    });
  }

  void _destroyBus() {
    _accountModifiedSub.cancel();
    }

  Future<void> _requestBalances(
      BuildContext context, List<Account> accounts) async {
    List<String>? addresses = List().cast<String>();
    for (var account in accounts) {
      addresses.add(account.address);
        }
    try {
      AccountsBalancesResponse resp =
          await sl.get<AccountService>().requestAccountsBalances(addresses);
      await _handleAccountsBalancesResponse(resp);
    } catch (e) {
      sl.get<Logger>().e("Error", error: e);
    }
  }

  Future<void> _changeAccount(Account account, StateSetter setState) async {
    // Change account
    for (var a in widget.accounts) {
      if (a.selected) {
        setState(() {
          a.selected = false;
        });
      } else if (account.index == a.index) {
        setState(() {
          a.selected = true;
        });
      }
    }
    await sl.get<DBHelper>().changeAccount(account);
    EventTaxiImpl.singleton()
        .fire(AccountChangedEvent(account: account, delayPop: true));
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
                margin: const EdgeInsets.only(top: 30.0, bottom: 15),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 140),
                child: AutoSizeText(
                  CaseChange.toUpperCase(
                      AppLocalization.of(context)!.accounts, context),
                  style: AppStyles.textStyleHeader(context),
                  maxLines: 1,
                  stepGranularity: 0.1,
                ),
              ),

              //A list containing accounts
              Expanded(
                  key: expandedKey,
                  child: Stack(
                    children: <Widget>[
                      // ignore: unnecessary_null_comparison
                      widget.accounts == null
                          ? const Center(
                              child: Text("Loading"),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              itemCount: widget.accounts.length,
                              controller: _scrollController,
                              itemBuilder: (BuildContext context, int index) {
                                return _buildAccountListItem(
                                    context, widget.accounts[index], setState);
                              },
                            ),
                      //List Top Gradient
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 20.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                StateContainer.of(context)!
                                    .curTheme
                                    .backgroundDark00,
                                StateContainer.of(context)!
                                    .curTheme
                                    .backgroundDark,
                              ],
                              begin: const AlignmentDirectional(0.5, 1.0),
                              end: const AlignmentDirectional(0.5, -1.0),
                            ),
                          ),
                        ),
                      ),
                      // List Bottom Gradient
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 20.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                StateContainer.of(context)!
                                    .curTheme
                                    .backgroundDark,
                                StateContainer.of(context)!
                                    .curTheme
                                    .backgroundDark00
                              ],
                              begin: const AlignmentDirectional(0.5, 1.0),
                              end: const AlignmentDirectional(0.5, -1.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 15,
              ),
              //A row with Add Account button
              Row(
                children: <Widget>[
                  widget.accounts.length >= MAX_ACCOUNTS
                      ? const SizedBox()
                      : AppButton.buildAppButton(
                          context,
                          AppButtonType.PRIMARY,
                          AppLocalization.of(context)!.addAccount,
                          Dimens.BUTTON_TOP_DIMENS,
                          disabled: _addingAccount,
                          onPressed: () {
                            if (!_addingAccount) {
                              setState(() {
                                _addingAccount = true;
                              });
                              StateContainer.of(context)!.getSeed().then((seed) {
                                sl
                                    .get<DBHelper>()
                                    .addAccount(seed,
                                        nameBuilder: AppLocalization.of(context)!
                                            .defaultNewAccountName)
                                    .then((newAccount) {
                                  _requestBalances(context, [newAccount]);
                                  StateContainer.of(context)!
                                      .updateRecentlyUsedAccounts();
                                  widget.accounts.add(newAccount);
                                  setState(() {
                                    _addingAccount = false;
                                    widget.accounts.sort(
                                        (a, b) => a.index.compareTo(b.index));
                                    // Scroll if list is full
                                    if (expandedKey.currentContext != null) {
                                      RenderObject? box = expandedKey.currentContext!
                                          .findRenderObject();
                                      if (widget.accounts.length * 72.0 >=
                                          box!.size.height) {
                                        _scrollController.animateTo(
                                          newAccount.index * 72.0 >
                                                  _scrollController
                                                      .position.maxScrollExtent
                                              ? _scrollController.position
                                                      .maxScrollExtent +
                                                  72.0
                                              : newAccount.index * 72.0,
                                          curve: Curves.easeOut,
                                          duration:
                                              const Duration(milliseconds: 200),
                                        );
                                      }
                                    }
                                  });
                                });
                              });
                            }
                          },
                        ),
                ],
              ),
              //A row with Close button
              Row(
                children: <Widget>[
                  AppButton.buildAppButton(
                    context,
                    AppButtonType.PRIMARY_OUTLINE,
                    AppLocalization.of(context)!.close,
                    Dimens.BUTTON_BOTTOM_DIMENS,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _buildAccountListItem(
      BuildContext context, Account account, StateSetter setState) {
    return Slidable(
      secondaryActions: _getSlideActionsForAccount(context, account, setState),
      actionExtentRatio: 0.2,
      actionPane: SlidableStrechActionPane(),
      delegate: null,
      onTriggered: null,
      child: FlatButton(
          highlightColor: StateContainer.of(context)!.curTheme.text15,
          splashColor: StateContainer.of(context)!.curTheme.text15,
          onPressed: () {
            if (!_accountIsChanging) {
              // Change account
              if (!account.selected) {
                setState(() {
                  _accountIsChanging = true;
                });
                _changeAccount(account, setState);
              }
            }
          },
          padding: const EdgeInsets.all(0.0),
          child: Column(
            children: <Widget>[
              Divider(
                height: 2,
                color: StateContainer.of(context)!.curTheme.text15,
              ),
              SizedBox(
                height: 70.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // Selected indicator
                    StateContainer.of(context)!.natriconOn
                        ? Container(
                            height: 70,
                            width: 6,
                            color: account.selected
                                ? StateContainer.of(context)!.curTheme.primary
                                : Colors.transparent,
                          )
                        : const SizedBox(),
                    // Icon, Account Name, Address and Amount
                    Expanded(
                      child: Container(
                        margin: EdgeInsetsDirectional.only(
                            start:
                                StateContainer.of(context)!.natriconOn ? 8 : 20,
                            end: StateContainer.of(context)!.natriconOn
                                ? 16
                                : 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                // natricon
                                StateContainer.of(context)!.natriconOn
                                    ? SizedBox(
                                        width: 64.0,
                                        height: 64.0,
                                        child: SvgPicture.network(
                                          UIUtil.getNatriconURL(
                                              account.address,
                                              StateContainer.of(context)!
                                                  .getNatriconNonce(
                                                      account.address)),
                                          key: Key(UIUtil.getNatriconURL(
                                              account.address,
                                              StateContainer.of(context)
                                                  !.getNatriconNonce(
                                                      account.address))),
                                          placeholderBuilder:
                                              (BuildContext context) =>
                                                  FlareActor(
                                                    "assets/ntr_placeholder_animation.flr",
                                                    animation: "main",
                                                    fit: BoxFit.contain,
                                                    color: StateContainer.of(context)!
                                                        .curTheme
                                                        .primary,
                                                  ),
                                        ),
                                      )
                                    : Stack(
                                      children: <Widget>[
                                        Center(
                                          child: Icon(
                                            AppIcons.accountwallet,
                                            color: account.selected
                                                ? StateContainer.of(context)!
                                                    .curTheme
                                                    .success
                                                : StateContainer.of(context)!
                                                    .curTheme
                                                    .primary,
                                            size: 30,
                                          ),
                                        ),
                                        Center(
                                          child: Container(
                                            width: 40,
                                            height: 30,
                                            alignment: const AlignmentDirectional(
                                                0, 0.3),
                                            child: Text(
                                                account
                                                    .getShortName()
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: StateContainer.of(
                                                          context)!
                                                      .curTheme
                                                      .backgroundDark,
                                                  fontSize: 12.0,
                                                  fontWeight:
                                                      FontWeight.w800,
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                // Account name and address
                                Container(
                                  width: (MediaQuery.of(context).size.width -
                                          116) *
                                      0.5,
                                  margin: EdgeInsetsDirectional.only(
                                      start:
                                          StateContainer.of(context)!.natriconOn
                                              ? 8.0
                                              : 20.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Account name
                                      AutoSizeText(
                                        account.name,
                                        style: TextStyle(
                                          fontFamily: "NunitoSans",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                          color: StateContainer.of(context)!
                                              .curTheme
                                              .text,
                                        ),
                                        minFontSize: 8.0,
                                        stepGranularity: 0.1,
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                      ),
                                      // Account address
                                      AutoSizeText(
                                        "${account.address.substring(0, 12)}...",
                                        style: TextStyle(
                                          fontFamily: "OverpassMono",
                                          fontWeight: FontWeight.w100,
                                          fontSize: 14.0,
                                          color: StateContainer.of(context)!
                                              .curTheme
                                              .text60,
                                        ),
                                        minFontSize: 8.0,
                                        stepGranularity: 0.1,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: (MediaQuery.of(context).size.width - 116) *
                                  0.4,
                              alignment: const AlignmentDirectional(1, 0),
                              child: AutoSizeText.rich(
                                TextSpan(
                                  children: [
                                    // Main balance text
                                    TextSpan(
                                      // ignore: unnecessary_null_comparison
                                      text: (account.balance != null
                                              ? "Ӿ"
                                              : "") +
                                          (!account.selected
                                              ? NumberUtil.getRawAsUsableString(
                                                  account.balance)
                                              : account.selected
                                                  ? StateContainer.of(context)!
                                                      .wallet
                                                      .getAccountBalanceDisplay()
                                                  : ""),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: "NunitoSans",
                                        fontWeight: FontWeight.w900,
                                        color: StateContainer.of(context)!
                                            .curTheme
                                            .text,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                style: const TextStyle(fontSize: 16.0),
                                stepGranularity: 0.1,
                                minFontSize: 1,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Selected indicator
                    StateContainer.of(context)!.natriconOn
                        ? Container(
                            height: 70,
                            width: 6,
                            color: account.selected
                                ? StateContainer.of(context)!.curTheme.primary
                                : Colors.transparent,
                          )
                        : const SizedBox()
                  ],
                ),
              ),
            ],
          )),
    );
  }

  List _getSlideActionsForAccount(
      BuildContext context, Account account, StateSetter setState) {
    List actions = List();
    actions.add(SlideAction(
        onTap: () {
          AccountDetailsSheet(account).mainBottomSheet(context);
        }, key: null, color: null, decoration: null,
        child: Container(
          margin: const EdgeInsetsDirectional.only(start: 2, top: 1, bottom: 1),
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: StateContainer.of(context)!.curTheme.primary,
          ),
          child: Icon(
            Icons.edit,
            color: StateContainer.of(context)!.curTheme.backgroundDark,
          ),
        ),));
    if (account.index > 0) {
      actions.add(SlideAction(
          onTap: () {
            AppDialogs.showConfirmDialog(
                context,
                AppLocalization.of(context)!.hideAccountHeader,
                AppLocalization.of(context)!
                    .removeAccountText
                    .replaceAll("%1", AppLocalization.of(context)!.addAccount),
                CaseChange.toUpperCase(
                    AppLocalization.of(context)!.yes, context), () {
              // Remove account
              sl.get<DBHelper>().deleteAccount(account).then((id) {
                EventTaxiImpl.singleton().fire(
                    AccountModifiedEvent(account: account, deleted: true));
                setState(() {
                  widget.accounts.removeWhere((a) => a.index == account.index);
                });
              });
            },
                cancelText: CaseChange.toUpperCase(
                    AppLocalization.of(context)!.no, context));
          }, key: null,
          color: null,
          decoration: null,
          child: Container(
            margin: const EdgeInsetsDirectional.only(start: 2, top: 1, bottom: 1),
            constraints: const BoxConstraints.expand(),
            decoration: BoxDecoration(
              color: StateContainer.of(context)!.curTheme.primary,
            ),
            child: Icon(
              Icons.delete,
              color: StateContainer.of(context)!.curTheme.backgroundDark,
            ),
          ),));
    }
    return actions;
  }
}
