import 'package:flutter/material.dart';
import 'package:web_app/constants/color.dart';
import 'package:web_app/constants/config.dart';

class MyTextButton extends StatelessWidget {
  final String title;
  final Color color;
  final double fontSize;
  final double elevation;
  final EdgeInsets padding;
  final VoidCallback onPressed;
  final BorderRadiusGeometry? borderRadius;

  const MyTextButton({
    Key? key,
    this.color = kPrimaryColor,
    this.fontSize = 17,
    this.borderRadius,
    this.elevation = 2,
    this.padding = const EdgeInsets.symmetric(
      vertical: 25,
      horizontal: 40,
    ),
    required this.onPressed,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: 0,
      color: color,
      padding: padding,
      onPressed: onPressed,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? kBorderRadius,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class MyIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;

  const MyIconButton({
    Key? key,
    this.onPressed,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kPrimaryColor,
      clipBehavior: Clip.hardEdge,
      shape: const CircleBorder(),
      child: IconButton(
        iconSize: 25,
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}
