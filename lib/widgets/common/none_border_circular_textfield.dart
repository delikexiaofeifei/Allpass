import 'package:flutter/material.dart';
import 'package:allpass/ui/allpass_ui.dart';

class NoneBorderCircularTextField extends StatelessWidget {
  final TextEditingController editingController;
  final String hintText;
  final String helperText;
  final String labelText;
  final String errorText;
  final Widget prefixIcon;
  final bool obscureText;
  final VoidCallback onEditingComplete;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;
  final TextAlign textAlign;
  final Widget trailing;
  final TextInputType inputType;
  final int maxLines;
  final bool autoFocus;

  final bool needPadding;

  NoneBorderCircularTextField({
    @required this.editingController,
    this.hintText,
    this.helperText,
    this.labelText,
    this.errorText,
    this.prefixIcon,
    this.textAlign: TextAlign.start,
    this.obscureText: false,
    this.maxLines: 1,
    this.onEditingComplete,
    this.trailing,
    this.autoFocus: false,
    this.inputType,
    this.onChanged,
    this.onTap,
    this.needPadding: true});

  @override
  Widget build(BuildContext context) {
    TextField common = TextField(
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        suffix: trailing,
        helperText: helperText,
        helperMaxLines: 3,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(
              Radius.circular(AllpassUI.smallBorderRadius)),
        ),
        labelText: labelText,
        errorText: errorText
      ),
      textAlign: textAlign,
      autofocus: autoFocus,
      keyboardType: inputType,
      maxLines: maxLines,
      controller: editingController,
      obscureText: obscureText,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      onTap: onTap,
    );
    if (needPadding) {
      return Padding(
        padding: AllpassEdgeInsets.smallTBPadding,
        child: common,
      );
    } else {
      return common;
    }
  }
}