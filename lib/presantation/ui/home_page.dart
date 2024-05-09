// ignore_for_file: use_build_context_synchronously, unnecessary_null_comparison, library_private_types_in_public_api, must_be_immutable

import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:event_taxi/event_taxi.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';
import 'package:near_pay_app/app_icons.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/presantation/bus/account_changed_event.dart';
import 'package:near_pay_app/presantation/bus/confirmation_height_changed_event.dart';
import 'package:near_pay_app/presantation/bus/contact_modified_event.dart';
import 'package:near_pay_app/presantation/bus/disable_lock_timeout_event.dart';
import 'package:near_pay_app/presantation/bus/fcm_update_event.dart';
import 'package:near_pay_app/presantation/bus/history_home_event.dart';
import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/core/models/address.dart';
import 'package:near_pay_app/core/models/db/account.dart';
import 'package:near_pay_app/core/models/db/appdb.dart';
import 'package:near_pay_app/core/models/db/contact.dart';
import 'package:near_pay_app/core/models/list_model.dart';
import 'package:near_pay_app/data/network/model/block_types.dart';
import 'package:near_pay_app/data/network/model/response/account_history_response_item.dart';
import 'package:near_pay_app/data/network/model/response/alerts_response_item.dart';
import 'package:near_pay_app/service_locator.dart';
import 'package:near_pay_app/styles.dart';
import 'package:near_pay_app/presantation/ui/contacts/add_contact.dart';
import 'package:near_pay_app/presantation/ui/popup_button.dart';
import 'package:near_pay_app/presantation/ui/receive/receive_sheet.dart';
import 'package:near_pay_app/presantation/ui/send/send_confirm_sheet.dart';
import 'package:near_pay_app/presantation/ui/send/send_sheet.dart';
// import 'package:near_pay_app/presantation/ui/settings/settings_drawer.dart';
import 'package:near_pay_app/presantation/ui/util/routes.dart';
import 'package:near_pay_app/presantation/ui/util/ui_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/presantation/ui/widgets/dialog.dart';
import 'package:near_pay_app/presantation/ui/widgets/flat_button.dart';
import 'package:near_pay_app/presantation/ui/widgets/list_slidable.dart';
import 'package:near_pay_app/presantation/ui/widgets/reactive_refresh.dart';
import 'package:near_pay_app/presantation/ui/widgets/remote_message_card.dart';
import 'package:near_pay_app/presantation/ui/widgets/remote_message_sheet.dart';
import 'package:near_pay_app/presantation/ui/widgets/sheet_util.dart';
import 'package:near_pay_app/presantation/utils/caseconverter.dart';
import 'package:near_pay_app/presantation/utils/sharedprefsutil.dart';
import 'package:nearpay_flutter_sdk/nearpay.dart';

class AppHomePage extends StatefulWidget {
  PriceConversion priceConversion;

  AppHomePage({super.key, required this.priceConversion});

  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage>
    with
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin,
        FlareController {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Logger log = sl.get<Logger>();

  // Controller for placeholder card animations
  late AnimationController _placeholderCardAnimationController;
  late Animation<double> _opacityAnimation;
  late bool _animationDisposed;

  // Manta
  late bool mantaAnimationOpen;

  // Receive card instance
  late ReceiveSheet receive;

  // A separate unfortunate instance of this list, is a little unfortunate
  // but seems the only way to handle the animations
  final Map<String, GlobalKey<AnimatedListState>> _listKeyMap = {};
  final Map<String, ListModel<AccountHistoryResponseItem>> _historyListMap =
      {};

  // List of contacts (Store it so we only have to query the DB once for transaction cards)
 

  // Price conversion state (BTC, NANO, NONE)
  late PriceConversion _priceConversion;

  bool _isRefreshing = false;

  bool _lockDisabled = false; // whether we should avoid locking the app
  bool _lockTriggered = false;

  // Main card height
  late double mainCardHeight;
  double settingsIconMarginTop = 5;
  // FCM instance
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Animation for swiping to send
  late ActorAnimation _sendSlideAnimation;
  late ActorAnimation _sendSlideReleaseAnimation;
  late double _fanimationPosition;
  bool releaseAnimation = false;

  @override
  void initialize(FlutterActorArtboard actor) {
    _fanimationPosition = 0.0;
    _sendSlideAnimation = actor.getAnimation("pull")!;
    _sendSlideReleaseAnimation = actor.getAnimation("release")!;
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    if (releaseAnimation) {
      _sendSlideReleaseAnimation.apply(
          _sendSlideReleaseAnimation.duration * (1 - _fanimationPosition),
          artboard,
          1.0);
    } else {
      _sendSlideAnimation.apply(
          _sendSlideAnimation.duration * _fanimationPosition, artboard, 1.0);
    }
    return true;
  }

  Future<void> _switchToAccount(String account) async {
    List accounts = await sl
        .get<DBHelper>()
        .getAccounts(await StateContainer.of(context)!.getSeed());
    for (Account a in accounts) {
      if (a.address == account &&
          a.address != StateContainer.of(context)!.wallet.address) {
        await sl.get<DBHelper>().changeAccount(a);
        EventTaxiImpl.singleton()
            .fire(AccountChangedEvent(account: a, delayPop: true));
      }
    }
  }

  /// Notification includes which account its for, automatically switch to it if they're entering app from notification
  Future<void> _chooseCorrectAccountFromNotification(dynamic message) async {
    if (message.containsKey("account")) {
      String account = message['account'];
      await _switchToAccount(account);
        }
  }

  void getNotificationPermissions() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(sound: true, badge: true, alert: true);
      if (settings.alert == AppleNotificationSetting.enabled ||
          settings.badge == AppleNotificationSetting.enabled ||
          settings.sound == AppleNotificationSetting.enabled ||
          settings.authorizationStatus == AuthorizationStatus.authorized) {
        sl.get<SharedPrefsUtil>().getNotificationsSet().then((beenSet) {
          if (!beenSet) {
            sl.get<SharedPrefsUtil>().setNotificationsOn(true);
          }
        });
        _firebaseMessaging.getToken().then((String token) {
          EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
                } as FutureOr Function(String? value));
      } else {
        sl.get<SharedPrefsUtil>().setNotificationsOn(false).then((_) {
          _firebaseMessaging.getToken().then((String token) {
            EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
          } as FutureOr Function(String? value));
        });
      }
      String? token = await _firebaseMessaging.getToken();
      EventTaxiImpl.singleton().fire(FcmUpdateEvent(token: token));
        } catch (e) {
      sl.get<SharedPrefsUtil>().setNotificationsOn(false);
    }
  }

  @override
  void initState() {
    super.initState();
    _registerBus();
    mantaAnimationOpen = false;
    WidgetsBinding.instance.addObserver(this);
    _priceConversion = widget.priceConversion;
      // Main Card Size
    if (_priceConversion == PriceConversion.BTC) {
      mainCardHeight = 120;
      settingsIconMarginTop = 7;
    } else if (_priceConversion == PriceConversion.NONE) {
      mainCardHeight = 64;
      settingsIconMarginTop = 7;
    } else if (_priceConversion == PriceConversion.HIDDEN) {
      mainCardHeight = 64;
      settingsIconMarginTop = 5;
    }
    _addSampleContact();
    _updateContacts();
    // Setup placeholder animation and start
    _animationDisposed = false;
    _placeholderCardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _placeholderCardAnimationController
        .addListener(_animationControllerListener);
    _opacityAnimation = Tween(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(
        parent: _placeholderCardAnimationController,
        curve: Curves.easeIn,
        reverseCurve: Curves.easeOut,
      ),
    );
    _opacityAnimation.addStatusListener(_animationStatusListener);
    _placeholderCardAnimationController.forward();
    // Register push notifications
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      try {
        await _chooseCorrectAccountFromNotification(message.data);
      // ignore: empty_catches
      } catch (e) {}
    });
    // Setup notification
    getNotificationPermissions();
  }

  void _animationStatusListener(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        _placeholderCardAnimationController.forward();
        break;
      case AnimationStatus.completed:
        _placeholderCardAnimationController.reverse();
        break;
      default:
        return;
    }
  }

  void _animationControllerListener() {
    setState(() {});
  }

  void _startAnimation() {
    if (_animationDisposed) {
      _animationDisposed = false;
      _placeholderCardAnimationController
          .addListener(_animationControllerListener);
      _opacityAnimation.addStatusListener(_animationStatusListener);
      _placeholderCardAnimationController.forward();
    }
  }

  void _disposeAnimation() {
    if (!_animationDisposed) {
      _animationDisposed = true;
      _opacityAnimation.removeStatusListener(_animationStatusListener);
      _placeholderCardAnimationController
          .removeListener(_animationControllerListener);
      _placeholderCardAnimationController.stop();
    }
  }

  /// Add donations contact if it hasnt already been added
  Future<void> _addSampleContact() async {
    bool contactAdded = await sl.get<SharedPrefsUtil>().getFirstContactAdded();
    if (!contactAdded) {
      bool addressExists = await sl.get<DBHelper>().contactExistsWithAddress(
          "nano_1natrium1o3z5519ifou7xii8crpxpk8y65qmkih8e8bpsjri651oza8imdd");
      if (addressExists) {
        return;
      }
      bool nameExists =
          await sl.get<DBHelper>().contactExistsWithName("@NatriumDonations");
      if (nameExists) {
        return;
      }
      await sl.get<SharedPrefsUtil>().setFirstContactAdded(true);
      Contact c = Contact(
          name: "@NatriumDonations",
          address:
              "nano_1natrium1o3z5519ifou7xii8crpxpk8y65qmkih8e8bpsjri651oza8imdd", monkeyPath: '', id: null);
      await sl.get<DBHelper>().saveContact(c);
    }
  }

  void _updateContacts() {
    sl.get<DBHelper>().getContacts().then((contacts) {
      setState(() {
        _contacts = contacts;
      });
    });
  }

  late StreamSubscription<ConfirmationHeightChangedEvent> _confirmEventSub;
  late StreamSubscription<HistoryHomeEvent> _historySub;
  late StreamSubscription<ContactModifiedEvent> _contactModifiedSub;
  late StreamSubscription<DisableLockTimeoutEvent> _disableLockSub;
  late StreamSubscription<AccountChangedEvent> _switchAccountSub;

  void _registerBus() {
    _historySub = EventTaxiImpl.singleton()
        .registerTo<HistoryHomeEvent>()
        .listen((event) {
      diffAndUpdateHistoryList(event.items);
      setState(() {
        _isRefreshing = false;
      });
      handleDeepLink(StateContainer.of(context)!.initialDeepLink);
      StateContainer.of(context)!.initialDeepLink = null;
        });
    _contactModifiedSub = EventTaxiImpl.singleton()
        .registerTo<ContactModifiedEvent>()
        .listen((event) {
      _updateContacts();
    });
    // Hackish event to block auto-lock functionality
    _disableLockSub = EventTaxiImpl.singleton()
        .registerTo<DisableLockTimeoutEvent>()
        .listen((event) {
      if (event.disable) {
        cancelLockEvent();
      }
      _lockDisabled = event.disable;
    });
    // User changed account
    _switchAccountSub = EventTaxiImpl.singleton()
        .registerTo<AccountChangedEvent>()
        .listen((event) {
      setState(() {
        StateContainer.of(context)!.wallet.loading = true;
        StateContainer.of(context)!.wallet.historyLoading = true;
        _startAnimation();
        StateContainer.of(context)!.updateWallet(account: event.account);
        currentConfHeight = -1;
      });
      paintQrCode(address: event.account.address);
      if (event.delayPop) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
        });
      } else if (!event.noPop) {
        Navigator.of(context).popUntil(RouteUtils.withNameLike("/home"));
      }
    });
    // Handle subscribe
    _confirmEventSub = EventTaxiImpl.singleton()
        .registerTo<ConfirmationHeightChangedEvent>()
        .listen((event) {
      updateConfirmationHeights(event.confirmationHeight);
    });
  }

  @override
  void dispose() {
    _destroyBus();
    WidgetsBinding.instance.removeObserver(this);
    _placeholderCardAnimationController.dispose();
    super.dispose();
  }

  void _destroyBus() {
    _historySub.cancel();
      _contactModifiedSub.cancel();
      _disableLockSub.cancel();
      _switchAccountSub.cancel();
      _confirmEventSub.cancel();
    }

  int currentConfHeight = -1;

  void updateConfirmationHeights(int confirmationHeight) {
    setState(() {
      currentConfHeight = confirmationHeight + 1;
    });
    if (!_historyListMap
        .containsKey(StateContainer.of(context)!.wallet.address)) {
      return;
    }
    List<int> unconfirmedUpdate = List();
    List<int> confirmedUpdate = List();
    for (int i = 0;
        i <
            _historyListMap[StateContainer.of(context)!.wallet.address]!
                .items
                .length;
        i++) {
      if ((_historyListMap[StateContainer.of(context)!.wallet.address]![i]
                  .confirmed) &&
          confirmationHeight <
              _historyListMap[StateContainer.of(context)!.wallet.address]![i]
                  .height) {
        unconfirmedUpdate.add(i);
      } else if ((!_historyListMap[StateContainer.of(context)!.wallet.address]![i]
                  .confirmed) &&
          confirmationHeight >=
              _historyListMap[StateContainer.of(context)!.wallet.address]![i]
                  .height) {
        confirmedUpdate.add(i);
      }
    }
    for (var element in unconfirmedUpdate) {
      setState(() {
        _historyListMap[StateContainer.of(context)!.wallet.address][element]
            .confirmed = false;
      });
    }
    for (var element in confirmedUpdate) {
      setState(() {
        _historyListMap[StateContainer.of(context)!.wallet.address]![element]
            .confirmed = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle websocket connection when app is in background
    // terminate it to be eco-friendly
    switch (state) {
      case AppLifecycleState.paused:
        setAppLockEvent();
        StateContainer.of(context)!.disconnect();
        super.didChangeAppLifecycleState(state);
        break;
      case AppLifecycleState.resumed:
        cancelLockEvent();
        StateContainer.of(context)!.reconnect();
        if (!StateContainer.of(context)!.wallet.loading &&
            !_lockTriggered) {
          handleDeepLink(StateContainer.of(context)!.initialDeepLink);
          StateContainer.of(context)!.initialDeepLink = null;
        }
        super.didChangeAppLifecycleState(state);
        break;
      default:
        super.didChangeAppLifecycleState(state);
        break;
    }
  }

  // To lock and unlock the app
  late StreamSubscription<dynamic> lockStreamListener;

  Future<void> setAppLockEvent() async {
    if (((await sl.get<SharedPrefsUtil>().getLock()) ||
            StateContainer.of(context)!.encryptedSecret != null) &&
        !_lockDisabled) {
      lockStreamListener.cancel();
          Future<dynamic> delayed = Future.delayed(
          (await sl.get<SharedPrefsUtil>().getLockTimeout()).getDuration());
      delayed.then((_) {
        return true;
      });
      lockStreamListener = delayed.asStream().listen((_) {
        try {
          StateContainer.of(context)?.resetEncryptedSecret();
        } catch (e) {
          log.w(
              "Failed to reset encrypted secret when locking ${e.toString()}");
        } finally {
          _lockTriggered = true;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
        }
      });
    }
  }

  Future<void> cancelLockEvent() async {
    lockStreamListener.cancel();
    }

  // Used to build list items that haven't been removed.
  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation) {
    if (index == 0) {
      return _buildRemoteMessageCard(StateContainer.of(context)!.activeAlert);
    }
    int localIndex = index;
    localIndex -= 1;
      String displayName = smallScreen(context)
        ? _historyListMap[StateContainer.of(context)!.wallet.address] != null?[localIndex]
            .getShorterString()
        : _historyListMap[StateContainer.of(context)!.wallet.address]?[localIndex]
            .getShortString();
    for (var contact in _contacts) {
      if (contact.address ==
          _historyListMap[StateContainer.of(context)!.wallet.address]![localIndex]
              .account
              .replaceAll("xrb_", "nano_")) {
        displayName = contact.name;
      }
    }

    return _buildTransactionCard(
        _historyListMap[StateContainer.of(context)!.wallet.address][localIndex],
        animation,
        displayName,
        context);
  }

  // Return widget for list
  Widget _getListWidget(BuildContext context) {
    if (StateContainer.of(context)!.wallet.historyLoading) {
      // Loading Animation
      return ReactiveRefreshIndicator(
          backgroundColor: StateContainer.of(context)!.curTheme.backgroundDark,
          onRefresh: _refresh,
          isRefreshing: _isRefreshing,
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
            children: <Widget>[
              _buildLoadingTransactionCard(
                  "Sent", "10244000", "123456789121234", context),
              _buildLoadingTransactionCard(
                  "Received", "100,00000", "@bbedwards1234", context),
              _buildLoadingTransactionCard(
                  "Sent", "14500000", "12345678912345671234", context),
              _buildLoadingTransactionCard(
                  "Sent", "12,51200", "123456789121234", context),
              _buildLoadingTransactionCard(
                  "Received", "1,45300", "123456789121234", context),
              _buildLoadingTransactionCard(
                  "Sent", "100,00000", "12345678912345671234", context),
              _buildLoadingTransactionCard(
                  "Received", "24,00000", "12345678912345671234", context),
              _buildLoadingTransactionCard(
                  "Sent", "1,00000", "123456789121234", context),
              _buildLoadingTransactionCard(
                  "Sent", "1,00000", "123456789121234", context),
              _buildLoadingTransactionCard(
                  "Sent", "1,00000", "123456789121234", context),
            ],
          ));
    } else if (StateContainer.of(context)!.wallet.history.isEmpty) {
      _disposeAnimation();
      return ReactiveRefreshIndicator(
        backgroundColor: StateContainer.of(context)!.curTheme.backgroundDark,
        onRefresh: _refresh,
        isRefreshing: _isRefreshing,
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
          children: <Widget>[
            // REMOTE MESSAGE CARD
            StateContainer.of(context)?.activeAlert != null
                ? _buildRemoteMessageCard(
                    StateContainer.of(context)!.activeAlert)
                : const SizedBox(),
            _buildWelcomeTransactionCard(context),
            _buildDummyTransactionCard(
                AppLocalization.of(context)!.sent,
                AppLocalization.of(context)!.exampleCardLittle,
                AppLocalization.of(context)!.exampleCardTo,
                context),
            _buildDummyTransactionCard(
                AppLocalization.of(context)!.received,
                AppLocalization.of(context)!.exampleCardLot,
                AppLocalization.of(context)!.exampleCardFrom,
                context),
          ],
        ),
      );
    } else {
      _disposeAnimation();
    }
    // Setup history list
    if (!_listKeyMap
        .containsKey("${StateContainer.of(context)!.wallet.address}alert")) {
      _listKeyMap.putIfAbsent(
          "${StateContainer.of(context)!.wallet.address}alert",
          () => GlobalKey<AnimatedListState>());
      setState(() {
        _historyListMap.putIfAbsent(
          StateContainer.of(context)!.wallet.address,
          () => ListModel<AccountHistoryResponseItem>(
            listKey: _listKeyMap[
                "${StateContainer.of(context)!.wallet.address}alert"],
            initialItems: StateContainer.of(context)!.wallet.history,
          ),
        );
      });
    }
    return ReactiveRefreshIndicator(
      backgroundColor: StateContainer.of(context)!.curTheme.backgroundDark,
      onRefresh: _refresh,
      isRefreshing: _isRefreshing,
      child: AnimatedList(
        key: _listKeyMap["${StateContainer.of(context)!.wallet.address}alert"],
        padding: const EdgeInsetsDirectional.fromSTEB(0, 5.0, 0, 15.0),
        initialItemCount:
            _historyListMap[StateContainer.of(context)!.wallet.address]!
                    .length +
                1,
        itemBuilder: _buildItem,
      ),
    );
      // Setup history list
  }

  // Refresh list
  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
    });
    sl.get<HapticUtil>().success();
    StateContainer.of(context)?.requestUpdate();
    // Hide refresh indicator after 3 seconds if no server response
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isRefreshing = false;
      });
    });
  }

  ///
  /// Because there's nothing convenient like DiffUtil, some manual logic
  /// to determine the differences between two lists and to add new items.
  ///
  /// Depends on == being overriden in the AccountHistoryResponseItem class
  ///
  /// Required to do it this way for the animation
  ///
  void diffAndUpdateHistoryList(List<AccountHistoryResponseItem> newList) {
    if (newList.isEmpty ||
        _historyListMap[StateContainer.of(context)!.wallet.address] == null) {
      return;
    }
    // Get items not in current list, and add them from top-down
    newList.reversed
        .where((item) =>
            !_historyListMap[StateContainer.of(context)!.wallet.address]!
                .items
                .contains(item))
        .forEach((historyItem) {
      setState(() {
        _historyListMap[StateContainer.of(context)!.wallet.address]!
            .insertAtTop(historyItem);
      });
    });
    // Re-subscribe if missing data
    if (StateContainer.of(context)!.wallet.loading) {
      StateContainer.of(context)!.requestSubscribe();
    } else {
      updateConfirmationHeights(
          StateContainer.of(context)!.wallet.confirmationHeight);
    }
  }

  Future<void> handleDeepLink(link) async {
    Address address = Address(link);
    if (address.isValid()) {
      String amount;
      String contactName;
      bool sufficientBalance = false;
      if (address.amount != null) {
        BigInt? amountBigInt = BigInt.tryParse(address.amount);
        // Require minimum 1 rai to send, and make sure sufficient balance
        if (amountBigInt! >= BigInt.from(10).pow(24)) {
          if (StateContainer.of(context)!.wallet.accountBalance > amountBigInt) {
            sufficientBalance = true;
          }
          amount = address.amount;
        }
      }
      // See if a contact
      Contact? contact =
          await sl.get<DBHelper>().getContactWithAddress(address.address);
      contactName = contact!.name;
          // Remove any other screens from stack
      Navigator.of(context).popUntil(RouteUtils.withNameLike('/home'));
      if (sufficientBalance) {
        // Go to send confirm with amount
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendConfirmSheet(
                amountRaw: amount,
                destination: address.address,
                contactName: contactName, localCurrency: '', natriconNonce: null,), color: null, barrier: null, onDisposed: null);
      } else {
        // Go to send with address
        Sheets.showAppHeightNineSheet(
            context: context,
            widget: SendSheet(
                localCurrency: StateContainer.of(context)!.curCurrency,
                contact: contact,
                address: address.address,
                quickSendAmount: amount), color: null, barrier: null, onDisposed: null);
      }
    } else if (MantaWallet.parseUrl(link) != null) {
      // Manta URI handling
      try {
        _showMantaAnimation();
        // Get manta payment request
        Nearpay manta = Nearpay(link);
        PaymentRequestMessage paymentRequest =
            await NearUtil.getPaymentDetails(manta);
        if (mantaAnimationOpen) {
          Navigator.of(context).pop();
        }
        NearUtil.processPaymentRequest(context, manta, paymentRequest);
      } catch (e) {
        if (mantaAnimationOpen) {
          Navigator.of(context).pop();
        }
        UIUtil.showSnackbar(AppLocalization.of(context)!.mantaError, context);
      }
    }
  }

  void _showMantaAnimation() {
    mantaAnimationOpen = true;
    Navigator.of(context).push(AnimationLoadingOverlay(
        AnimationType.MANTA,
        StateContainer.of(context)!.curTheme.animationOverlayStrong,
        StateContainer.of(context)!.curTheme.animationOverlayMedium,
        onPoppedCallback: () => mantaAnimationOpen = false));
  }

  void paintQrCode({required String address}) {
    QrPainter painter = QrPainter(
      data:
          address,
      version: 6,
      gapless: false,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    );
    painter.toImageData(MediaQuery.of(context).size.width).then((byteData) {
      setState(() {
        receive = ReceiveSheet(
          qrWidget: SizedBox(
              width: MediaQuery.of(context).size.width / 1,
              child: Image.memory(byteData.buffer.asUint8List())),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Create QR ahead of time because it improves performance this way
    if (receive == null) {
      paintQrCode(address: '');
    }

    return Scaffold(
      drawerEdgeDragWidth: 200,
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      backgroundColor: StateContainer.of(context)!.curTheme.background,
      drawerScrimColor: StateContainer.of(context)!.curTheme.barrierWeaker,
      drawer: SizedBox(
        width: UIUtil.drawerWidth(context),
        child: const Drawer(
          child: SettingsSheet(),
        ),
      ),
      body: SafeArea(
        minimum: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.045,
            bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  //Everything else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      //Main Card
                      _buildMainCard(context, _scaffoldKey),
                      //Main Card End
                      //Transactions Text
                      Container(
                        margin: const EdgeInsetsDirectional.fromSTEB(
                            30.0, 20.0, 26.0, 0.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              CaseChange.toUpperCase(
                                  AppLocalization.of(context)!.transactions,
                                  context),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.w100,
                                color: StateContainer.of(context)!.curTheme.text,
                              ),
                            ),
                          ],
                        ),
                      ), //Transactions Text End
                      //Transactions List
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            _getListWidget(context),
                            //List Top Gradient End
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                height: 10.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      StateContainer.of(context)!
                                          .curTheme
                                          .background00,
                                      StateContainer.of(context)!
                                          .curTheme
                                          .background
                                    ],
                                    begin: const AlignmentDirectional(0.5, 1.0),
                                    end: const AlignmentDirectional(0.5, -1.0),
                                  ),
                                ),
                              ),
                            ), // List Top Gradient End
                            //List Bottom Gradient
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 30.0,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      StateContainer.of(context)!
                                          .curTheme
                                          .background00,
                                      StateContainer.of(context)!
                                          .curTheme
                                          .background
                                    ],
                                    begin: const AlignmentDirectional(0.5, -1),
                                    end: const AlignmentDirectional(0.5, 0.5),
                                  ),
                                ),
                              ),
                            ), //List Bottom Gradient End
                          ],
                        ),
                      ), //Transactions List End
                      //Buttons background
                      SizedBox(
                        height: 55,
                        width: MediaQuery.of(context).size.width,
                      ), //Buttons background
                    ],
                  ),
                  // Buttons
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            StateContainer.of(context)!.curTheme.boxShadowButton
                          ],
                        ),
                        height: 55,
                        width: (MediaQuery.of(context).size.width - 42) / 2,
                        margin: const EdgeInsetsDirectional.only(
                            start: 14, top: 0.0, end: 7.0),
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100.0)),
                          color: receive != null
                              ? StateContainer.of(context)!.curTheme.primary
                              : StateContainer.of(context)!.curTheme.primary60,
                          onPressed: () {
                            Sheets.showAppHeightEightSheet(
                                context: context, widget: receive, color: null, barrier: null);
                          },
                          highlightColor: receive != null
                              ? StateContainer.of(context)!.curTheme.background40
                              : Colors.transparent,
                          splashColor: receive != null
                              ? StateContainer.of(context)!.curTheme.background40
                              : Colors.transparent,
                          child: AutoSizeText(
                            AppLocalization.of(context)!.receive,
                            textAlign: TextAlign.center,
                            style: AppStyles.textStyleButtonPrimary(context),
                            maxLines: 1,
                            stepGranularity: 0.5,
                          ),
                        ),
                      ),
                      const AppPopupButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteMessageCard(AlertResponseItem alert) {
    if (alert == null) {
      return const SizedBox();
    }
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14, 4, 14, 4),
      child: RemoteMessageCard(
        alert: alert,
        onPressed: () {
          Sheets.showAppHeightEightSheet(
            context: context,
            widget: RemoteMessageSheet(
              alert: alert,
            ), color: null, barrier: null,
          );
        },
      ),
    );
  }

  // Transaction Card/List Item
  Widget _buildTransactionCard(AccountHistoryResponseItem item,
      Animation<double> animation, String displayName, BuildContext context) {
    String text;
    IconData icon;
    Color iconColor;
    if (item.type == BlockTypes.SEND) {
      text = AppLocalization.of(context)!.sent;
      icon = AppIcons.sent;
      iconColor = StateContainer.of(context)!.curTheme.text60;
    } else {
      text = AppLocalization.of(context)!.received;
      icon = AppIcons.received;
      iconColor = StateContainer.of(context)!.curTheme.primary60;
    }
    return Slidable(
      // ignore: prefer_const_constructors
      delegate:  SlidableScrollDelegate(),
      actionExtentRatio: 0.35,
      movementDuration: const Duration(milliseconds: 300),
      enabled: StateContainer.of(context)!.wallet.accountBalance > BigInt.zero,
      onTriggered: (preempt) {
        if (preempt) {
          setState(() {
            releaseAnimation = true;
          });
        } else {
          // See if a contact
          sl
              .get<DBHelper>()
              .getContactWithAddress(item.account)
              .then((contact) {
            // Go to send with address
            Sheets.showAppHeightNineSheet(
                context: context,
                widget: SendSheet(
                  localCurrency: StateContainer.of(context)!.curCurrency,
                  contact: contact,
                  address: item.account,
                  quickSendAmount: item.amount,
                ), color: null, barrier: null, onDisposed: null);
          });
        }
      },
      onAnimationChanged: (animation) {
        if (animation != null) {
          _fanimationPosition = animation.value;
          if (animation.value == 0.0 && releaseAnimation) {
            setState(() {
              releaseAnimation = false;
            });
          }
        }
      },
      secondaryActions: <Widget>[
        SlideAction(
          key: null,
          onTap: () {  },
          color: null,
          decoration: null,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            margin: EdgeInsetsDirectional.only(
                end: MediaQuery.of(context).size.width * 0.15,
                top: 4,
                bottom: 4),
            child: Container(
              alignment: const AlignmentDirectional(-0.5, 0),
              constraints: const BoxConstraints.expand(),
              child: FlareActor("assets/pulltosend_animation.flr",
                  animation: "pull",
                  fit: BoxFit.contain,
                  controller: this,
                  color: StateContainer.of(context)!.curTheme.primary),
            ),
          ),
        ),
      ],
      key: null,
      actions: const [],
      child: _SizeTransitionNoClip(
        sizeFactor: animation,
        child: Container(
          margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
          decoration: BoxDecoration(
            color: StateContainer.of(context)!.curTheme.backgroundDark,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [StateContainer.of(context)!.curTheme.boxShadow],
          ),
          child: FlatButton(
            highlightColor: StateContainer.of(context)!.curTheme.text15,
            splashColor: StateContainer.of(context)!.curTheme.text15,
            color: StateContainer.of(context)!.curTheme.backgroundDark,
            padding: const EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            onPressed: () {
              Sheets.showAppHeightEightSheet(
                  context: context,
                  widget: TransactionDetailsSheet(
                      hash: item.hash,
                      address: item.account,
                      displayName: displayName),
                  animationDurationMs: 175, color: null, barrier: null);
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                            margin: const EdgeInsetsDirectional.only(end: 16.0),
                            child: Icon(icon, color: iconColor, size: 20)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                text,
                                textAlign: TextAlign.start,
                                style:
                                    AppStyles.textStyleTransactionType(context),
                              ),
                              RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  text: '',
                                  children: [
                                    TextSpan(
                                      text: "Ӿ${item.getFormattedAmount()}",
                                      style:
                                          AppStyles.textStyleTransactionAmount(
                                        context,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            displayName,
                            textAlign: TextAlign.end,
                            style:
                                AppStyles.textStyleTransactionAddress(context),
                          ),

                          // // TRANSACTION STATE TAG
                          // (item.confirmed != null && !item.confirmed) ||
                          //         (currentConfHeight > -1 &&
                          //             item.height != null &&
                          //             item.height > currentConfHeight)
                          //     ? Container(
                          //         margin: EdgeInsetsDirectional.only(
                          //           top: 4,
                          //         ),
                          //         child: TransactionStateTag(
                          //             transactionState:
                          //                 TransactionStateOptions.UNCONFIRMED),
                          //       )
                          //     : SizedBox()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  } //Transaction Card End

  // Dummy Transaction Card
  Widget _buildDummyTransactionCard(
      String type, String amount, String address, BuildContext context) {
    String text;
    IconData icon;
    Color iconColor;
    if (type == AppLocalization.of(context)!.sent) {
      text = AppLocalization.of(context)!.sent;
      icon = AppIcons.sent;
      iconColor = StateContainer.of(context)!.curTheme.text60;
    } else {
      text = AppLocalization.of(context)!.received;
      icon = AppIcons.received;
      iconColor = StateContainer.of(context)!.curTheme.primary60;
    }
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context)!.curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context)!.curTheme.boxShadow],
      ),
      child: FlatButton(
        onPressed: () {
          return;
        },
        highlightColor: StateContainer.of(context)!.curTheme.text15,
        splashColor: StateContainer.of(context)!.curTheme.text15,
        color: StateContainer.of(context)!.curTheme.backgroundDark,
        padding: const EdgeInsets.all(0.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                        margin: const EdgeInsetsDirectional.only(end: 16.0),
                        child: Icon(icon, color: iconColor, size: 20)),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            text,
                            textAlign: TextAlign.start,
                            style: AppStyles.textStyleTransactionType(context),
                          ),
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              text: '',
                              children: [
                                TextSpan(
                                  text: "$amount NANO",
                                  style: AppStyles.textStyleTransactionAmount(
                                    context,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.4,
                  child: Text(
                    address,
                    textAlign: TextAlign.end,
                    style: AppStyles.textStyleTransactionAddress(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } //Dummy Transaction Card End

  // Welcome Card
  TextSpan _getExampleHeaderSpan(BuildContext context) {
    String workingStr;
    if (StateContainer.of(context)!.selectedAccount.index == 0) {
      workingStr = AppLocalization.of(context)!.exampleCardIntro;
    } else {
      workingStr = AppLocalization.of(context)!.newAccountIntro;
    }
    if (!workingStr.contains("NANO")) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }
    // Colorize NANO
    List<String> splitStr = workingStr.split("NANO");
    if (splitStr.length != 2) {
      return TextSpan(
        text: workingStr,
        style: AppStyles.textStyleTransactionWelcome(context),
      );
    }
    return TextSpan(
      text: '',
      children: [
        TextSpan(
          text: splitStr[0],
          style: AppStyles.textStyleTransactionWelcome(context),
        ),
        TextSpan(
          text: "NANO",
          style: AppStyles.textStyleTransactionWelcomePrimary(context),
        ),
        TextSpan(
          text: splitStr[1],
          style: AppStyles.textStyleTransactionWelcome(context),
        ),
      ],
    );
  }

  Widget _buildWelcomeTransactionCard(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context)!.curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context)!.curTheme.boxShadow],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0)),
                color: StateContainer.of(context)!.curTheme.primary,
                boxShadow: [StateContainer.of(context)!.curTheme.boxShadow],
              ),
            ),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 15.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: _getExampleHeaderSpan(context),
                ),
              ),
            ),
            Container(
              width: 7.0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0)),
                color: StateContainer.of(context)!.curTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  } // Welcome Card End

  // Loading Transaction Card
  Widget _buildLoadingTransactionCard(
      String type, String amount, String address, BuildContext context) {
    String text;
    IconData icon;
    Color iconColor;
    if (type == "Sent") {
      text = "Senttt";
      icon = AppIcons.dotfilled;
      iconColor = StateContainer.of(context)!.curTheme.text20;
    } else {
      text = "Receiveddd";
      icon = AppIcons.dotfilled;
      iconColor = StateContainer.of(context)!.curTheme.primary20;
    }
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(14.0, 4.0, 14.0, 4.0),
      decoration: BoxDecoration(
        color: StateContainer.of(context)!.curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context)!.curTheme.boxShadow],
      ),
      child: FlatButton(
        onPressed: () {
          return;
        },
        highlightColor: StateContainer.of(context)!.curTheme.text15,
        splashColor: StateContainer.of(context)!.curTheme.text15,
        color: StateContainer.of(context)!.curTheme.backgroundDark,
        padding: const EdgeInsets.all(0.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Transaction Icon
                    Opacity(
                      opacity: _opacityAnimation.value,
                      child: Container(
                          margin: const EdgeInsetsDirectional.only(end: 16.0),
                          child: Icon(icon, color: iconColor, size: 20)),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Transaction Type Text
                          Stack(
                            alignment: const AlignmentDirectional(-1, 0),
                            children: <Widget>[
                              Text(
                                text,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontFamily: "NunitoSans",
                                  fontSize: AppFontSizes.small,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.transparent,
                                ),
                              ),
                              Opacity(
                                opacity: _opacityAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context)!
                                        .curTheme
                                        .text45,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    text,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                      fontFamily: "NunitoSans",
                                      fontSize: AppFontSizes.small - 4,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Amount Text
                          Stack(
                            alignment: const AlignmentDirectional(-1, 0),
                            children: <Widget>[
                              Text(
                                amount,
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                    fontFamily: "NunitoSans",
                                    color: Colors.transparent,
                                    fontSize: AppFontSizes.smallest,
                                    fontWeight: FontWeight.w600),
                              ),
                              Opacity(
                                opacity: _opacityAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: StateContainer.of(context)!
                                        .curTheme
                                        .primary20,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    amount,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        fontFamily: "NunitoSans",
                                        color: Colors.transparent,
                                        fontSize: AppFontSizes.smallest - 3,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Address Text
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Stack(
                        alignment: const AlignmentDirectional(1, 0),
                        children: <Widget>[
                          Text(
                            address,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: AppFontSizes.smallest,
                              fontFamily: 'OverpassMono',
                              fontWeight: FontWeight.w100,
                              color: Colors.transparent,
                            ),
                          ),
                          Opacity(
                            opacity: _opacityAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: StateContainer.of(context)!
                                    .curTheme
                                    .text20,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                address,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                  fontSize: AppFontSizes.smallest - 3,
                                  fontFamily: 'OverpassMono',
                                  fontWeight: FontWeight.w100,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } // Loading Transaction Card End

  //Main Card
  Widget _buildMainCard(BuildContext context, scaffoldKey) {
    return Container(
      decoration: BoxDecoration(
        color: StateContainer.of(context)!.curTheme.backgroundDark,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [StateContainer.of(context)!.curTheme.boxShadow],
      ),
      margin: EdgeInsets.only(
          left: 14.0,
          right: 14.0,
          top: MediaQuery.of(context).size.height * 0.005),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 80.0,
            height: mainCardHeight,
            alignment: const AlignmentDirectional(-1, -1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: EdgeInsetsDirectional.only(
                  top: settingsIconMarginTop, start: 5),
              height: 50,
              width: 50,
              child: FlatButton(
                highlightColor: StateContainer.of(context)!.curTheme.text15,
                splashColor: StateContainer.of(context)!.curTheme.text15,
                onPressed: () {
                  scaffoldKey.currentState.openDrawer();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0)),
                padding: const EdgeInsets.all(0.0),
                child: Stack(
                  children: [
                    Icon(
                      AppIcons.settings,
                      color: StateContainer.of(context)!.curTheme.text,
                      size: 24,
                    ),
                    !StateContainer.of(context)!.activeAlertIsRead
                        ?
                        // Unread message dot
                        Positioned(
                            top: -3,
                            right: -3,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: StateContainer.of(context)!
                                    .curTheme
                                    .backgroundDark,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: StateContainer.of(context)!
                                      .curTheme
                                      .success,
                                  shape: BoxShape.circle,
                                ),
                                height: 11,
                                width: 11,
                              ),
                            ),
                          )
                        : const SizedBox()
                  ],
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: mainCardHeight,
            curve: Curves.easeInOut,
            child: _getBalanceWidget(),
          ),
          // natricon
          StateContainer.of(context)!.natriconOn
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: mainCardHeight == 64 ? 60 : 74,
                  height: mainCardHeight == 64 ? 60 : 74,
                  margin: const EdgeInsets.only(right: 2),
                  alignment: const Alignment(0, 0),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Hero(
                          tag: "avatar",
                          child: StateContainer.of(context)!
                                      .selectedAccount
                                      .address !=
                                  null
                              ? SvgPicture.network(
                                  UIUtil.getNatriconURL(
                                      StateContainer.of(context)!
                                          .selectedAccount
                                          .address,
                                      StateContainer.of(context)!
                                          .getNatriconNonce(
                                              StateContainer.of(context)
                                                  !.selectedAccount
                                                  .address)),
                                  key: Key(UIUtil.getNatriconURL(
                                      StateContainer.of(context)!
                                          .selectedAccount
                                          .address,
                                      StateContainer.of(context)
                                          !.getNatriconNonce(
                                              StateContainer.of(context)
                                                  !.selectedAccount
                                                  .address))),
                                  placeholderBuilder:
                                      (BuildContext context) => FlareActor(
                                        "assets/ntr_placeholder_animation.flr",
                                        animation: "main",
                                        fit: BoxFit.contain,
                                        color: StateContainer.of(context)!
                                            .curTheme
                                            .primary,
                                      ),
                                )
                              : const SizedBox(),
                        ),
                      ),
                      Center(
                        child: Container(
                          color: Colors.transparent,
                          child: FlatButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/avatar_page');
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0)),
                            highlightColor:
                                StateContainer.of(context)!.curTheme.text15,
                            splashColor:
                                StateContainer.of(context)!.curTheme.text15,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: 80.0,
                  height: mainCardHeight,
                ),
        ],
      ),
    );
  } //Main Card

  // Get balance display
  Widget _getBalanceWidget() {
    if (StateContainer.of(context)!.wallet.loading) {
      // Placeholder for balance text
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _priceConversion == PriceConversion.BTC
              ? Stack(
                alignment: const AlignmentDirectional(0, 0),
                children: <Widget>[
                  const Text(
                    "1234567",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "NunitoSans",
                        fontSize: AppFontSizes.small,
                        fontWeight: FontWeight.w600,
                        color: Colors.transparent),
                  ),
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: StateContainer.of(context)!.curTheme.text20,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        "1234567",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "NunitoSans",
                            fontSize: AppFontSizes.small - 3,
                            fontWeight: FontWeight.w600,
                            color: Colors.transparent),
                      ),
                    ),
                  ),
                ],
              )
              : const SizedBox(),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 225),
            child: Stack(
              alignment: const AlignmentDirectional(0, 0),
              children: <Widget>[
                const AutoSizeText(
                  "1234567",
                  style: TextStyle(
                      fontFamily: "NunitoSans",
                      fontSize: AppFontSizes.largestc,
                      fontWeight: FontWeight.w900,
                      color: Colors.transparent),
                  maxLines: 1,
                  stepGranularity: 0.1,
                  minFontSize: 1,
                ),
                Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: StateContainer.of(context)!.curTheme.primary60,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const AutoSizeText(
                      "1234567",
                      style: TextStyle(
                          fontFamily: "NunitoSans",
                          fontSize: AppFontSizes.largestc - 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.transparent),
                      maxLines: 1,
                      stepGranularity: 0.1,
                      minFontSize: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _priceConversion == PriceConversion.BTC
              ? Stack(
                alignment: const AlignmentDirectional(0, 0),
                children: <Widget>[
                  const Text(
                    "1234567",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "NunitoSans",
                        fontSize: AppFontSizes.small,
                        fontWeight: FontWeight.w600,
                        color: Colors.transparent),
                  ),
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: StateContainer.of(context)!.curTheme.text20,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        "1234567",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "NunitoSans",
                            fontSize: AppFontSizes.small - 3,
                            fontWeight: FontWeight.w600,
                            color: Colors.transparent),
                      ),
                    ),
                  ),
                ],
              )
              : const SizedBox(),
        ],
      );
    }
    // Balance texts
    return GestureDetector(
      onTap: () {
        if (_priceConversion == PriceConversion.BTC) {
          // Hide prices
          setState(() {
            _priceConversion = PriceConversion.NONE;
            mainCardHeight = 64;
            settingsIconMarginTop = 7;
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.NONE);
        } else if (_priceConversion == PriceConversion.NONE) {
          // Cyclce to hidden
          setState(() {
            _priceConversion = PriceConversion.HIDDEN;
            mainCardHeight = 64;
            settingsIconMarginTop = 7;
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.HIDDEN);
        } else if (_priceConversion == PriceConversion.HIDDEN) {
          // Cycle to BTC price
          setState(() {
            mainCardHeight = 120;
            settingsIconMarginTop = 5;
          });
          Future.delayed(const Duration(milliseconds: 150), () {
            setState(() {
              _priceConversion = PriceConversion.BTC;
            });
          });
          sl.get<SharedPrefsUtil>().setPriceConversion(PriceConversion.BTC);
        }
      },
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width - 190,
        color: Colors.transparent,
        child: _priceConversion == PriceConversion.HIDDEN
            ?
            // Nano logo
            Center(
                child: Icon(AppIcons.nanologo,
                    size: 32,
                    color: StateContainer.of(context)!.curTheme.primary))
            : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _priceConversion == PriceConversion.BTC
                    ? Text(
                        StateContainer.of(context)!
                            .wallet
                            .getLocalCurrencyPrice(
                                StateContainer.of(context)!.curCurrency,
                                locale: StateContainer.of(context)!
                                    .currencyLocale),
                        textAlign: TextAlign.center,
                        style: AppStyles.textStyleCurrencyAlt(context))
                    : const SizedBox(height: 0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width - 205),
                      child: AutoSizeText.rich(
                        TextSpan(
                          children: [
                            // Main balance text
                            TextSpan(
                              text: "Ӿ${StateContainer.of(context)!
                                      .wallet
                                      .getAccountBalanceDisplay()}",
                              style: _priceConversion ==
                                      PriceConversion.BTC
                                  ? AppStyles.textStyleCurrency(context)
                                  : AppStyles.textStyleCurrencySmaller(
                                      context,
                                    ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        style: TextStyle(
                            fontSize:
                                _priceConversion == PriceConversion.BTC
                                    ? 28
                                    : 22),
                        stepGranularity: 0.1,
                        minFontSize: 1,
                        maxFontSize:
                            _priceConversion == PriceConversion.BTC
                                ? 28
                                : 22,
                      ),
                    ),
                  ],
                ),
                _priceConversion == PriceConversion.BTC
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                              _priceConversion == PriceConversion.BTC
                                  ? AppIcons.btc
                                  : AppIcons.currency,
                              color:
                                  _priceConversion == PriceConversion.NONE
                                      ? Colors.transparent
                                      : StateContainer.of(context)!
                                          .curTheme
                                          .text60,
                              size: 14),
                          Text(StateContainer.of(context)!.wallet.btcPrice,
                              textAlign: TextAlign.center,
                              style:
                                  AppStyles.textStyleCurrencyAlt(context)),
                        ],
                      )
                    : const SizedBox(height: 0),
              ],
            ),
      ),
    );
  }
}


class TransactionDetailsSheet extends StatefulWidget {
  final String hash;
  final String address;
  final String displayName;

  const TransactionDetailsSheet({super.key, required this.hash, required this.address, required this.displayName});

  @override
  _TransactionDetailsSheetState createState() =>
      _TransactionDetailsSheetState();
}

class _TransactionDetailsSheetState extends State<TransactionDetailsSheet> {
  // Current state references
  bool _addressCopied = false;
  // Timer reference so we can cancel repeated events
  late Timer _addressCopiedTimer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.035,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(
              children: <Widget>[
                // A stack for Copy Address and Add Contact buttons
                Stack(
                  children: <Widget>[
                    // A row for Copy Address Button
                    Row(
                      children: <Widget>[
                        AppButton.buildAppButton(
                            context,
                            // Share Address Button
                            _addressCopied
                                ? AppButtonType.SUCCESS
                                : AppButtonType.PRIMARY,
                            _addressCopied
                                ? AppLocalization.of(context)!.addressCopied
                                : AppLocalization.of(context)!.copyAddress,
                            Dimens.BUTTON_TOP_EXCEPTION_DIMENS, onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: widget.address));
                          if (mounted) {
                            setState(() {
                              // Set copied style
                              _addressCopied = true;
                            });
                          }
                          _addressCopiedTimer.cancel();
                                                  _addressCopiedTimer =
                              Timer(const Duration(milliseconds: 800), () {
                            if (mounted) {
                              setState(() {
                                _addressCopied = false;
                              });
                            }
                          });
                        }),
                      ],
                    ),
                    // A row for Add Contact Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsetsDirectional.only(
                              top: Dimens.BUTTON_TOP_EXCEPTION_DIMENS[1],
                              end: Dimens.BUTTON_TOP_EXCEPTION_DIMENS[2]),
                          child: SizedBox(
                            height: 55,
                            width: 55,
                            // Add Contact Button
                            child: !widget.displayName.startsWith("@")
                                ? FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Sheets.showAppHeightNineSheet(
                                          context: context,
                                          widget: AddContactSheet(
                                              address: widget.address), color: null, barrier: null, onDisposed: null);
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(100.0)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10),
                                    child: Icon(AppIcons.addcontact,
                                        size: 35,
                                        color: _addressCopied
                                            ? StateContainer.of(context)!
                                                .curTheme
                                                .successDark
                                            : StateContainer.of(context)!
                                                .curTheme
                                                .backgroundDark),
                                  )
                                : const SizedBox(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // A row for View Details button
                Row(
                  children: <Widget>[
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY_OUTLINE,
                        AppLocalization.of(context)!.viewDetails,
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return UIUtil.showBlockExplorerWebview(
                            context, widget.hash);
                      }));
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
}

/// This is used so that the elevation of the container is kept and the
/// drop shadow is not clipped.
///
class _SizeTransitionNoClip extends AnimatedWidget {
  final Widget child;

  const _SizeTransitionNoClip(
      {required Animation<double> sizeFactor, required this.child})
      : super(listenable: sizeFactor);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(-1.0, -1.0),
      widthFactor: null,
      heightFactor: (listenable as Animation<double>).value,
      child: child,
    );
  }
}
