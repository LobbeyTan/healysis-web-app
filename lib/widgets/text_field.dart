import 'package:flutter/material.dart';
import 'package:web_app/constants/color.dart';
import 'package:web_app/constants/config.dart';

class RoundedTextField extends StatelessWidget {
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final Icon? suffixIcon;
  final Color borderColor;
  final BorderRadius? borderRadius;
  final BoxConstraints? suffixIconConstraints;
  final EdgeInsets? contentPadding;
  final TextEditingController? controller;

  const RoundedTextField({
    Key? key,
    this.maxLength,
    this.controller,
    this.suffixIcon,
    this.borderRadius,
    this.suffixIconConstraints,
    this.maxLines = 1,
    this.enabled = true,
    this.borderColor = kLightGreyColor,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 20,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        suffixIconConstraints: suffixIconConstraints,
        contentPadding: contentPadding,
        border: OutlineInputBorder(
          borderRadius: borderRadius ?? kBorderRadius,
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
      ),
      style: const TextStyle(
        fontSize: kNormalFontSize,
      ),
    );
  }
}