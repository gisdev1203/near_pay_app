// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, duplicate_ignore, unnecessary_null_comparison

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:event_taxi/event_taxi.dart';
import 'package:near_pay_app/app_icons.dart';
import 'package:near_pay_app/appstate_container.dart';
import 'package:near_pay_app/core/models/address.dart';
import 'package:near_pay_app/core/models/db/appdb.dart';
import 'package:near_pay_app/core/models/db/contact.dart';

import 'package:near_pay_app/dimens.dart';
import 'package:near_pay_app/localization.dart';
import 'package:near_pay_app/presantation/bus/contact_added_event.dart';
import 'package:near_pay_app/presantation/bus/contact_modified_event.dart';
import 'package:near_pay_app/presantation/ui/util/formatters.dart';
import 'package:near_pay_app/presantation/ui/util/ui_util.dart';
import 'package:near_pay_app/presantation/ui/widgets/app_text_field.dart';
import 'package:near_pay_app/presantation/ui/widgets/buttons.dart';
import 'package:near_pay_app/presantation/ui/widgets/tap_outside_unfocus.dart';
import 'package:near_pay_app/presantation/utils/caseconverter.dart';
import 'package:near_pay_app/presantation/utils/user_data_util.dart';

import 'package:near_pay_app/service_locator.dart';
import 'package:near_pay_app/styles.dart';



class AddContactSheet extends StatefulWidget {
  final String address;

  const AddContactSheet({super.key, required this.address});

  @override
  _AddContactSheetState createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<AddContactSheet> {
  late FocusNode _nameFocusNode;
  late FocusNode _addressFocusNode;
  late TextEditingController _nameController;
  late TextEditingController _addressController;

  // State variables
  late bool _addressValid;
  late bool _showPasteButton;
  late bool _showNameHint;
  late bool _showAddressHint;
  late String _nameValidationText;
  late String _addressValidationText;

  @override
  void initState() {
    super.initState();
    // Text field initialization
    _nameFocusNode = FocusNode();
    _addressFocusNode = FocusNode();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    // State initializationrue;
    _addressValid = false;
    _showPasteButton = true;
    _showNameHint = true;
    _showAddressHint = true;
    _nameValidationText = "";
    _addressValidationText = "";
    // Add focus listeners
    // On name focus change
    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus) {
        setState(() {
          _showNameHint = false;
        });
      } else {
        setState(() {
          _showNameHint = true;
        });
      }
    });
    // On address focus change
    _addressFocusNode.addListener(() {
      if (_addressFocusNode.hasFocus) {
        setState(() {
          _showAddressHint = false;
        });
        _addressController.selection = TextSelection.fromPosition(
            TextPosition(offset: _addressController.text.length));
      } else {
        setState(() {
          _showAddressHint = true;
          if (Address(_addressController.text).isValid()) {
          }
        });
      }
    });
  }

  /// Return true if textfield should be shown, false if colorized should be shown
  bool _shouldShowTextField() {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return TapOutsideUnfocus(
      child: SafeArea(
        minimum: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.035),
        child: Column(
          children: <Widget>[
            // Top row of the sheet which contains the header and the scan qr button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Empty SizedBox
                const SizedBox(
                  width: 60,
                  height: 60,
                ),
                // The header of the sheet
                Container(
                  margin: const EdgeInsets.only(top: 30.0),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 140),
                  child: Column(
                    children: <Widget>[
                      AutoSizeText(
                        CaseChange.toUpperCase(
                            AppLocalization.of(context)!.addContact,
                            context),
                        style: AppStyles.textStyleHeader(context),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        stepGranularity: 0.1,
                      ),
                    ],
                  ),
                ),

                // Scan QR Button
                const SizedBox(
                  width: 60,
                  height: 60
                ),
              ],
            ),

            // The main container that holds "Enter Name" and "Enter Address" text fields
            Expanded(
              child: KeyboardAvoider(
                duration: const Duration(milliseconds: 0),
                autoScroll: true,
                focusPadding: 40,
                child: Column(
                children: <Widget>[
                  // Enter Name Container
                  AppTextField(
                    topMargin: MediaQuery.of(context).size.height * 0.14,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                        focusNode: _nameFocusNode,
                        controller: _nameController,
                        textInputAction: widget.address != null
                            ? TextInputAction.done
                            : TextInputAction.next,
                        hintText: _showNameHint
                            ? AppLocalization.of(context)!
                                .contactNameHint
                            : "",
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: StateContainer.of(context)!
                              .curTheme
                              .text,
                          fontFamily: 'NunitoSans',
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                          ContactInputFormatter()
                        ],
                        onSubmitted: (text) {
                          FocusScope.of(context).unfocus();
                                                },
                      ),
                      // Enter Name Error Container
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Text(_nameValidationText,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: StateContainer.of(context)!
                                  .curTheme
                                  .primary,
                              fontFamily: 'NunitoSans',
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      // Enter Address container
                      AppTextField(
                        padding: !_shouldShowTextField()
                            ? const EdgeInsets.symmetric(
                                horizontal: 25.0, vertical: 15.0)
                            : EdgeInsets.zero,                        
                        focusNode: _addressFocusNode,
                        controller: _addressController,
                        style: _addressValid
                            ? AppStyles.textStyleAddressText90(
                                context)
                            : AppStyles.textStyleAddressText60(
                                context),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(65),
                        ],
                        textInputAction: TextInputAction.done,
                        maxLines: null,
                        autocorrect: false,
                        hintText: _showAddressHint
                            ? AppLocalization.of(context)!
                                .addressHint
                            : "",
                        prefixButton: TextFieldButton(
                          icon: AppIcons.scan,
                          onPressed: () async {
                            UIUtil.cancelLockEvent();
                            String? scanResult = await UserDataUtil.getQRData(DataType.ADDRESS, context);
                            if (!QRScanErrs.ERROR_LIST.contains(scanResult)) {
                            if (mounted) {
                              setState(() {
                                _addressController.text = scanResult!;
                                _addressValidationText = "";
                                _addressValid = true;
                              });
                              _addressFocusNode.unfocus();
                            }
                          }
                          }
                        ),
                        fadePrefixOnCondition: true,
                        prefixShowFirstCondition: _showPasteButton,
                        suffixButton: TextFieldButton(
                          icon: AppIcons.paste,
                          onPressed: () async {
                            if (!_showPasteButton) {
                              return;
                            }
                            String? data = await UserDataUtil.getClipboardText(DataType.ADDRESS);
                            setState(() {
                              _addressValid = true;
                              _showPasteButton = false;
                              _addressController.text = data!;
                            });
                            _addressFocusNode.unfocus();
                                                    },
                        ),
                        fadeSuffixOnCondition: true,
                        suffixShowFirstCondition: _showPasteButton,
                        onChanged: (text) {
                          Address address = Address(text);
                          if (address.isValid()) {
                            setState(() {
                              _addressValid = true;
                              _showPasteButton = false;
                              _addressController.text =
                                  address.address;
                            });
                            _addressFocusNode.unfocus();
                          } else {
                            setState(() {
                              _showPasteButton = true;
                              _addressValid = false;
                            });
                          }
                        },
                        overrideTextFieldWidget: 
                          !_shouldShowTextField()
                          ? GestureDetector(
                              onTap: () {
                                return;
                              },
                              child: UIUtil.threeLineAddressText(
                                  context,
                                  widget.address, contactName: '')
                          ) : null,
                    ),
                    // Enter Address Error Container
                    Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 5),
                      child: Text(_addressValidationText,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: StateContainer.of(context)!
                                .curTheme
                                .primary,
                            fontFamily: 'NunitoSans',
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ],
                ),
              ),
            ),
            //A column with "Add Contact" and "Close" buttons
            Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    // Add Contact Button
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY,
                        AppLocalization.of(context)!.addContact,
                        Dimens.BUTTON_TOP_DIMENS, onPressed: () async {
                      if (await validateForm()) {
                        Contact newContact = Contact(
                            name: _nameController.text,
                            address: widget.address, monkeyPath: '', id: null);
                        await sl.get<DBHelper>().saveContact(newContact);
                        newContact.address = newContact.address.replaceAll("xrb_", "nano_");
                        EventTaxiImpl.singleton().fire(
                            ContactAddedEvent(contact: newContact));
                        UIUtil.showSnackbar(
                            AppLocalization.of(context)!
                                .contactAdded
                                .replaceAll("%1", newContact.name),
                            context);
                        EventTaxiImpl.singleton().fire(
                            ContactModifiedEvent(
                                contact: newContact));
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      }
                    }),
                  ],
                ),
                Row(
                  children: <Widget>[
                    // Close Button
                    AppButton.buildAppButton(
                        context,
                        AppButtonType.PRIMARY_OUTLINE,
                        AppLocalization.of(context)!.close,
                        Dimens.BUTTON_BOTTOM_DIMENS, onPressed: () {
                      Navigator.pop(context);
                    }),
                  ],
                ),
              ],
            ),
          ],
        ),
      )
    );
  }

  Future<bool> validateForm() async {
    bool isValid = true;
    // Name Validations
    if (_nameController.text.isEmpty) {
      isValid = false;
      setState(() {
        _nameValidationText = AppLocalization.of(context)!.contactNameMissing;
      });
    } else {
      bool nameExists =
          await sl.get<DBHelper>().contactExistsWithName(_nameController.text);
      if (nameExists) {
        setState(() {
          isValid = false;
          _nameValidationText = AppLocalization.of(context)!.contactExists;
        });
      }
    }
    return isValid;
  }
}
