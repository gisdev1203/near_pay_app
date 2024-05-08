// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';

class FlatButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final VoidCallback onLongPress;
  final ValueChanged<bool> onHighlightChanged;
  final MouseCursor mouseCursor;
  final ButtonTextTheme textTheme;
  final Color textColor;
  final Color disabledTextColor;
  final Color color;
  final Color disabledColor;
  final Color focusColor;
  final Color hoverColor;
  final Color highlightColor;
  final Color splashColor;
  final Brightness colorBrightness;
  final EdgeInsetsGeometry padding;
  final VisualDensity visualDensity;
  final ShapeBorder shape;
  final Clip clipBehavior;
  final FocusNode focusNode;
  final bool autofocus;
  final MaterialTapTargetSize materialTapTargetSize;
  final double height;
  final double minWidth;

  const FlatButton({
    required Key key,
    required this.onPressed,
    required this.child,
    required this.onLongPress,
    required this.onHighlightChanged,
    required this.mouseCursor,
    required this.textTheme,
    required this.textColor,
    required this.disabledTextColor,
    required this.color,
    required this.disabledColor,
    required this.focusColor,
    required this.hoverColor,
    required this.highlightColor,
    required this.splashColor,
    required this.colorBrightness,
    required this.padding,
    required this.visualDensity,
    required this.shape,
    this.clipBehavior = Clip.none,
    required this.focusNode,
    this.autofocus = false,
    required this.materialTapTargetSize,
    required this.height,
    required this.minWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert FlatButton properties to TextButton properties.
    final ButtonStyle style = ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) return disabledColor;
          return color;
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) return disabledTextColor;
          return textColor;
        },
      ),
      overlayColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) return splashColor;
          if (states.contains(MaterialState.hovered)) return hoverColor;
          if (states.contains(MaterialState.focused)) return focusColor;
          return null;
        },
      ),
      mouseCursor:
          mouseCursor != null ? MaterialStateProperty.all(mouseCursor) : null,
      shape: shape != null
          ? MaterialStateProperty.all(shape as OutlinedBorder?)
          : MaterialStateProperty.all(
              const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
      padding: MaterialStateProperty.all(padding),
      visualDensity: visualDensity,
      tapTargetSize: materialTapTargetSize,
      minimumSize: (height != null || minWidth != null)
          ? MaterialStateProperty.all(Size(minWidth, height))
          : null,
    );

    return TextButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: style,
      clipBehavior: clipBehavior,
      autofocus: autofocus,
      focusNode: focusNode,
      child: child,
    );
  }
}
