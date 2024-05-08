// ignore_for_file: constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/styles.dart';


enum TransactionStateOptions { UNCONFIRMED, CONFIRMED }

class TransactionStateTag extends StatelessWidget {
  final TransactionStateOptions transactionState;

  const TransactionStateTag({required Key key, required this.transactionState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(6, 2, 6, 2),
      decoration: BoxDecoration(
        color: StateContainer.of(context)!.curTheme.text10,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        transactionState == TransactionStateOptions.UNCONFIRMED
            ? AppLocalization.of(context)!.unconfirmed
            : "tag",
        style: AppStyles.tagText(context),
      ),
    );
  }
}
