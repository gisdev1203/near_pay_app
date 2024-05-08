// ignore_for_file: annotate_overrides, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/models/setting_item.dart';


enum NotificationOptions { ON, OFF }

/// Represent notification on/off setting
class NotificationSetting extends SettingSelectionItem {
  NotificationOptions setting;

  NotificationSetting(this.setting);

  String? getDisplayName(BuildContext context) {
    switch (setting) {
      case NotificationOptions.ON:
        return AppLocalization.of(context)?.onStr;
      case NotificationOptions.OFF:
      default:
        return AppLocalization.of(context)?.off;
    }
  }

  // For saving to shared prefs
  int getIndex() {
    return setting.index;
  }
}