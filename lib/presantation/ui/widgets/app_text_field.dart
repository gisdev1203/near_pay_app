// ignore_for_file: library_private_types_in_public_api, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:near_pay_app/appstate_container.dart';

import 'flat_button.dart';


/// TextField button
class TextFieldButton extends StatelessWidget {
  final IconData icon;
  final Function onPressed;

  const TextFieldButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 48,
        width: 48,
        child: FlatButton(
          padding: const EdgeInsets.all(14.0),
          highlightColor: StateContainer.of(context)!.curTheme.primary15,
          splashColor: StateContainer.of(context)!.curTheme.primary30,
          onPressed: () {
            onPressed != null ? onPressed() : null;
          },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200.0)),
          child: Icon(icon,
              size: 20, color: StateContainer.of(context)!.curTheme.primary),
        ));
  }
}

/// A widget for our custom textfields
class AppTextField extends StatefulWidget {
  final TextAlign textAlign;
  final FocusNode focusNode;
  final TextEditingController controller;
  final Color cursorColor;
  final Brightness keyboardAppearance;
  final List<TextInputFormatter> inputFormatters;
  final TextInputAction textInputAction;
  final int maxLines;
  final bool autocorrect;
  final String hintText;
  final TextFieldButton prefixButton;
  final TextFieldButton suffixButton;
  final bool fadePrefixOnCondition;
  final bool prefixShowFirstCondition;
  final bool fadeSuffixOnCondition;
  final bool suffixShowFirstCondition;
  final EdgeInsetsGeometry padding;
  final Widget overrideTextFieldWidget;
  final int buttonFadeDurationMs;
  final TextInputType keyboardType;
  final Function onSubmitted;
  final Function onChanged;
  final double topMargin;
  final double leftMargin;
  final double rightMargin;
  final TextStyle style;
  final bool obscureText;
  final bool autofocus;

  const AppTextField(
      {super.key, required this.focusNode,
      required this.controller,
      required this.cursorColor,
      required this.inputFormatters,
      required this.textInputAction,
      required this.hintText,
      required this.prefixButton,
      required this.suffixButton,
      required this.fadePrefixOnCondition,
      required this.prefixShowFirstCondition,
      required this.fadeSuffixOnCondition,
      required this.suffixShowFirstCondition,
      required this.overrideTextFieldWidget,
      required this.keyboardType,
      required this.onSubmitted,
      required this.onChanged,
      required this.style,
      required this.leftMargin,
      required this.rightMargin,
      this.obscureText = false,
      this.textAlign = TextAlign.center,
      this.keyboardAppearance = Brightness.dark,
      this.autocorrect = true,
      this.maxLines = 1,
      this.padding = EdgeInsets.zero,
      this.buttonFadeDurationMs = 100,
      this.topMargin = 0,
      this.autofocus = false});

  @override
  _AppTextFieldState createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
          left: widget.leftMargin,
          right:
              widget.rightMargin,
          top: widget.topMargin,
        ),
        padding: widget.padding,
        width: double.infinity,
        decoration: BoxDecoration(
          color: StateContainer.of(context)!.curTheme.backgroundDarkest,
          borderRadius: BorderRadius.circular(25),
        ),
        child: widget.overrideTextFieldWidget);
  }
}
