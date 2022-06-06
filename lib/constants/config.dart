import 'package:flutter/material.dart';
import 'package:web_app/constants/color.dart';

const double kRadius = 20;

BorderRadius kBorderRadius = BorderRadius.circular(20);

const double kBigTitleFontSize = 25;

const double kHeaderFontSize = 22;

const double kNormalFontSize = 18;

const List<Map<String, dynamic>> kMenuItem = [
  {
    "title": "Dashboard",
    "icon": Icons.dashboard_customize,
    "route": "/",
  },
  {
    "title": "Analytic",
    "icon": Icons.analytics,
    "route": "/analytic",
  },
  {
    "title": "Dataset",
    "icon": Icons.dataset,
    "route": "/dataset",
  },
  {
    "title": "Settings",
    "icon": Icons.settings,
    "route": "/setting",
  },
];

const Map<String, String> sentimentLabels = {
  'pos': 'Positive',
  'neg': 'Negative',
  'neu': 'Neutral',
};

const Map<String, Color> sentimentColors = {
  'pos': kYellowColor,
  'neg': kTaleColor,
  'neu': kGreyColor,
};
