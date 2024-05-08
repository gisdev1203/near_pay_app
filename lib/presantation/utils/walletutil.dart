import 'package:flutter/material.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/core/models/address.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/ui/send/send_confirm_sheet.dart';
import 'package:near_pay_app/presantation/ui/util/ui_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/sheet_util.dart';
import 'package:near_pay_app/presantation/utils/numberutil.dart';


import 'package:pointycastle/asymmetric/api.dart' show RSAPublicKey;

class NearUtil {
  // Utilities for the near protocol
  static Future<PaymentRequestMessage> getPaymentDetails(NearPay near) async {
    await near.connect();
    final RSAPublicKey cert = await near.getCertificate();
    final PaymentRequestEnvelope payReqEnv = await near.getPaymentRequest(
      cryptoCurrency: "NEAR");
    if (!payReqEnv.verify(cert)) {
      throw 'Certificate verification failure';
    }
    final PaymentRequestMessage payReq = payReqEnv.unpack();
    return payReq;
  }

  static void processPaymentRequest(BuildContext context, NearWallet near, PaymentRequestMessage paymentRequest) {
      // Validate account balance and destination as valid
      Destination dest = paymentRequest.destinations[0];
      String rawAmountStr = NumberUtil.getAmountAsRaw(dest.amount.toString());
      BigInt? rawAmount = BigInt.tryParse(rawAmountStr);
      if (!Address(dest.destination_address).isValid()) {
        UIUtil.showSnackbar(AppLocalization.of(context)!.qrInvalidAddress, context);
      } else if (rawAmount > StateContainer.of(context)!.wallet.accountBalance) {
        UIUtil.showSnackbar(AppLocalization.of(context)!.insufficientBalance, context);
      } else if (rawAmount < BigInt.from(10).pow(24)) {
        UIUtil.showSnackbar(AppLocalization.of(context)!.minimumSend.replaceAll("%1", "0.000001"), context);
      } else {
        // Is valid, proceed
        Sheets.showAppHeightNineSheet(
          context: context,
          widget: SendConfirmSheet(
                    amountRaw: rawAmountStr,
                    destination: dest.destination_address,
                    near: near,
                    paymentRequest: paymentRequest, contactName: '', localCurrency: '', natriconNonce: null,
          ), barrier: null, onDisposed: null, color: null
        );
      }    
  }
}
