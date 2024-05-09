import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:near_pay_app/core/models/available_currency.dart';
import 'package:near_pay_app/data/network/model/response/account_history_response_item.dart';
import 'package:near_pay_app/presantation/utils/numberutil.dart';


/// Main wallet object that's passed around the app via state
class AppWallet {
  static const String defaultRepresentative =
      'nano_1natrium1o3z5519ifou7xii8crpxpk8y65qmkih8e8bpsjri651oza8imdd';

  bool loading; // Whether or not app is initially loading
  bool
      historyLoading; // Whether or not we have received initial account history response
  String address;
  BigInt accountBalance;
  String frontier;
  String openBlock;
  String representativeBlock;
  String representative;
  String _localCurrencyPrice;
  String _btcPrice;
  int blockCount;
  int confirmationHeight;
  List<AccountHistoryResponseItem> history;

  AppWallet(
      {required String address,
      required BigInt accountBalance,
      required String frontier,
      required String openBlock,
      required String representativeBlock,
      required String representative,
      required String localCurrencyPrice,
      required String btcPrice,
      required int blockCount,
      required List<AccountHistoryResponseItem> history,
      required bool loading,
      required bool historyLoading,
      this.confirmationHeight = -1}) {
    address = address;
    accountBalance = accountBalance;
    frontier = frontier;
    openBlock = openBlock;
    representativeBlock = representativeBlock;
    representative = representative;
    _localCurrencyPrice = localCurrencyPrice;
    _btcPrice = btcPrice;
    blockCount = blockCount;
    history = history;
    loading = loading;
    historyLoading = historyLoading;
  }

  // Get pretty account balance version
  String getAccountBalanceDisplay() {
    try {
      return NumberUtil.getRawAsUsableString(accountBalance.toString());
    } catch (e) {
      return "N/A";
    }
  }

  String getLocalCurrencyPrice(AvailableCurrency currency,
      {String locale = "en_US"}) {
    try {
      Decimal converted = Decimal.parse(_localCurrencyPrice) *
          NumberUtil.getRawAsUsableDecimal(accountBalance.toString());
      return NumberFormat.currency(
              locale: locale, symbol: currency.getCurrencySymbol())
          .format(converted.toDouble());
    } catch (e) {
      return "N/A";
    }
  }

  set localCurrencyPrice(String value) {
    _localCurrencyPrice = value;
  }

  String get localCurrencyConversion {
    return _localCurrencyPrice;
  }

  String get btcPrice {
    try {
      Decimal converted = Decimal.parse(_btcPrice) *
          NumberUtil.getRawAsUsableDecimal(accountBalance.toString());
      // Show 4 decimal places for BTC price if its >= 0.0001 BTC, otherwise 6 decimals
      if (converted >= Decimal.parse("0.0001")) {
        return NumberFormat("#,##0.0000", "en_US")
            .format(converted.toDouble());
      } else {
        return NumberFormat("#,##0.000000", "en_US")
            .format(converted.toDouble());
      }
    } catch (e) {
      return "N/A";
    }
  }

  set btcPrice(String value) {
    _btcPrice = value;
  }
}
