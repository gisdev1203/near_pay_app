// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:near_pay_app/core/models/setting_item.dart';
import 'package:near_pay_app/localization.dart';



enum UnlockOption { YES, NO }

/// Represent authenticate to open setting
class UnlockSetting extends SettingSelectionItem {
  UnlockOption setting;

  UnlockSetting(this.setting);

  @override
  String? getDisplayName(BuildContext context) {
    switch (setting) {
      case UnlockOption.YES:
        return AppLocalization.of(context)?.yes;
      case UnlockOption.NO:
      default:
        return AppLocalization.of(context)?.no;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}