// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:near_pay_app/core/models/setting_item.dart';
import 'package:near_pay_app/localization.dart';



enum NatriconOptions { ON, OFF }

/// Represent natricon on/off setting
class NatriconSetting extends SettingSelectionItem {
  NatriconOptions setting;

  NatriconSetting(this.setting);

  @override
  String? getDisplayName(BuildContext context) {
    switch (setting) {
      case NatriconOptions.ON:
        return AppLocalization.of(context)?.onStr;
      case NatriconOptions.OFF:
      default:
        return AppLocalization.of(context)?.off;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}