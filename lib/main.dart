import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_app/firebase_options.dart';
import 'package:web_app/models/review.dart';
import 'package:web_app/screens/analytic.dart';
import 'package:web_app/screens/dashboard.dart';
import 'package:web_app/screens/dataset.dart';
import 'package:web_app/screens/setting.dart';
import 'package:web_app/utils/request.dart';
import 'package:web_app/utils/storage.dart';
import 'package:web_app/utils/stt.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WebApp());
}

class WebApp extends StatelessWidget {
  const WebApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => StorageController()),
        Provider(create: (_) => SpeechToTextController()),
        Provider(create: (_) => APIController()),
        Provider(create: (_) => ReviewModel(firestore: FirebaseFirestore.instance))
      ],
      child: MaterialApp(
        title: 'Healysis',
        debugShowCheckedModeBanner: false,
        routes: {
          "/": (context) => const DashboardScreen(),
          "/analytic": (context) => const AnalyticScreen(),
          "/dataset": (context) => const DatasetScreen(),
          "/setting": (context) => const SettingScreen(),
        },
      ),
    );
  }
}
