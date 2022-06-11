import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

extension DateTimeExtention on DateTime {
  Timestamp toTimeStamp() {
    return Timestamp.fromDate(this);
  }

  Timestamp toCurrentDateStartTime() {
    return Timestamp.fromDate(DateTime(year, month, day));
  }
}

class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
