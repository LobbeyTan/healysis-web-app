import 'package:flutter/material.dart';
import 'package:web_app/constants/config.dart';

class CardContainer extends StatelessWidget {
  final EdgeInsets? contentPadding;
  final Widget child;

  const CardContainer({
    Key? key,
    this.contentPadding,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        padding: contentPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: kBorderRadius,
          boxShadow: [
            BoxShadow(
              blurRadius: 7,
              spreadRadius: 5,
              color: Colors.grey.withOpacity(0.1),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
