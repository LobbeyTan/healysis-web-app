import 'package:flutter/material.dart';
import 'package:web_app/widgets/layout.dart';

class SettingScreen extends StatelessWidget {
  static const pageRoute = "/setting";

  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyCustomLayout(
      pageRoute: pageRoute,
      child: Container(),
    );
  }
}
