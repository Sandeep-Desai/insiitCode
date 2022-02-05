import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insiit/features/bottomNavBar/navbar.dart';
import 'package:insiit/features/map/main_page.dart';
import 'package:insiit/global/data/constants.dart';
import 'package:insiit/global/theme/notifier.dart';
import 'package:insiit/home/main_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage(this.notifyParent, {Key? key}) : super(key: key);
  final Function() notifyParent;
  @override
  _HomePageState createState() => _HomePageState();
}

bool mainPageLoading = true;
int selectedIndex = 0;
List<int> prevIndexes = [];

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  PageController pageController = PageController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(selectedIndex);
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  List<String> titles = ["", "Buses", "Campus Map", "Misc"];

  Widget homeScreen() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.backgroundColor,
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: theme.bottomNavyBarColor,
        selectedIndex: selectedIndex,
        showElevation: true,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        onItemSelected: (index) {
          selectedIndex = index;
          pageController.jumpToPage(index);
          setState(() {});
        },
        items: [
          BottomNavyBarItem(
            icon: Icon(Icons.apps, color: theme.textSubheadingColor),
            title: Text(
              'Home',
              style: TextStyle(color: theme.textSubheadingColor),
            ),
            activeColor: theme.bottomNavyBarIndicatorColor,
            inactiveColor: Colors.grey,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.airport_shuttle, color: theme.textSubheadingColor),
            title: Text(
              'Shuttle',
              style: TextStyle(color: theme.textSubheadingColor),
            ),
            activeColor: theme.bottomNavyBarIndicatorColor,
            inactiveColor: Colors.grey,
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: Icon(
              Icons.map,
              color: theme.textSubheadingColor,
            ),
            textAlign: TextAlign.center,
            title: Text(
              'Map',
              style: TextStyle(color: theme.textSubheadingColor),
            ),
            activeColor: theme.bottomNavyBarIndicatorColor,
            inactiveColor: Colors.grey,
          ),
          BottomNavyBarItem(
            icon: Icon(Icons.menu, color: theme.textSubheadingColor),
            title: Text(
              'Misc',
              style: TextStyle(color: theme.textSubheadingColor),
            ),
            textAlign: TextAlign.center,
            activeColor: theme.bottomNavyBarIndicatorColor,
            inactiveColor: Colors.grey,
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            (darkMode) ? Icons.wb_sunny : Icons.wb_sunny_outlined,
            color: (darkMode) ? Colors.purple : Colors.black,
          ),
          onPressed: () {
            if (darkMode) {
              darkMode = false;
            } else {
              darkMode = true;
            }
            swapTheme(darkMode);
            setState(() {});
          },
        ),
        title: Container(
            decoration: BoxDecoration(
                color: (titles[selectedIndex] == "")
                    ? Colors.transparent
                    : theme.backgroundColor.withAlpha(150),
                borderRadius: const BorderRadius.all(Radius.circular(40))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(titles[selectedIndex],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textHeadingColor)),
            )),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey.withAlpha(100)),
            onPressed: () {
              // reloadData(forceRefresh: true);
              // dataContainer.schedule.buildData();
              // RELOAD TODO
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.grey.withAlpha(100)),
            onPressed: () {
              // TODO
              // dataContainer.auth.logoutUser().then((value) {
              //   Navigator.pushReplacementNamed(context, '/signin');
              // });
            },
          )
        ],
        centerTitle: true,
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (index) {
          setState(() => selectedIndex = index);
        },
        children: <Widget>[
          const MainHomePage(),
          MapPage(),
          // MainHomePage(),
          // MainHomePage(),
          // FeedPage(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (mainPageLoading == true) {
      // return loadScreen();
    } else {
      // dataContainer.schedule.buildData();
      return WillPopScope(onWillPop: _onBackPressed, child: homeScreen());
    }
    return WillPopScope(onWillPop: _onBackPressed, child: homeScreen());
  }

  Future<bool> _onBackPressed() {
    bool value = false;
    if (selectedIndex != 0) {
      pageController.jumpToPage(0);
      value = true;
    }
    return Future.value(value);
  }

  @override
  bool get wantKeepAlive => true;
}
