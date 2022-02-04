import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:insiit/features/mess/ui/feedback_page.dart';
import 'package:insiit/features/mess/ui/main_page.dart';
import 'package:insiit/global/data/constants.dart';
import 'package:insiit/home/home_container.dart';
import 'package:path_provider/path_provider.dart';
import 'home/main_home_page.dart';
import 'data/data_container.dart';
import 'global/data/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //     // apiKey: 'AIzaSyAHAsf51D0A407EklG1bs-5wA7EbyfNFg0',
  //     // appId: '1:448618578101:ios:2bc5c1fe2ec336f8ac3efc',
  //     // messagingSenderId: '448618578101',
  //     // projectId: 'react-native-firebase-testing',
  //     // databaseURL: 'https://react-native-firebase-testing.firebaseio.com',
  //     // storageBucket: 'react-native-firebase-testing.appspot.com',
  //   ),
  // );
  var dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  dataContainer = DataContainer();

  await dataContainer.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final navigatorKey = GlobalKey<NavigatorState>();

  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      key: navigatorKey,
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomeWrapper(),
        '/messmenu': (context) => const MessMenu(),
        '/messfeedback': (context) => MessFeedBack(),
      },
      title: 'InsIIT',
      theme: ThemeData(fontFamily: 'OpenSans'),
    );
  }
}

class HomeWrapper extends StatelessWidget {
  const HomeWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenSize.size = MediaQuery.of(context).size;
    return HomePage(() {});
  }
}
