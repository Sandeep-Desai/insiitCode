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
