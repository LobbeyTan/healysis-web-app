import 'package:flutter/material.dart';
import 'package:web_app/constants/color.dart';
import 'package:web_app/constants/config.dart';
import 'package:web_app/widgets/menu.dart';

class MyCustomLayout extends StatelessWidget {
  final String pageRoute;
  final Widget child;

  const MyCustomLayout({
    Key? key,
    required this.child,
    required this.pageRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kPrimaryColor,
        child: Row(
          children: [
            MainMenu(
              pageRoute: pageRoute,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: kLightWhiteColor,
                    borderRadius: kBorderRadius,
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
