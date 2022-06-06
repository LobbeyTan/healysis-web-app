import 'package:cloud_firestore/cloud_firestore.dart';

extension DateTimeExtention on DateTime {
  Timestamp toTimeStamp() {
    return Timestamp.fromDate(this);
  }

  Timestamp toCurrentDateStartTime() {
    return Timestamp.fromDate(DateTime(year, month, day));
  }
}
