import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:insiit/features/mess/ui/home_widget.dart';
import 'package:insiit/global/classes/user.dart';
import 'package:insiit/global/data/constants.dart';
import 'dart:math';
import 'package:insiit/global/theme/notifier.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({Key? key}) : super(key: key);

  @override
  _MainHomePageState createState() => _MainHomePageState();
}

// replaces
// dataContainer.auth.user -> user

class _MainHomePageState extends State<MainHomePage>
    with AutomaticKeepAliveClientMixin<MainHomePage> {
  bool connected = true;
  User user = dataContainer.user;
  String quote = '';
  String quoteAuthor = '';

  @override
  void initState() {
    super.initState();

    if (dataContainer.generalData.quotes.isNotEmpty) {
      int quoteIndex =
          Random().nextInt(dataContainer.generalData.quotes.length);
      quote = dataContainer.generalData.quotes[quoteIndex]['text'];
      quoteAuthor = dataContainer.generalData.quotes[quoteIndex]['author'];
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return (SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 60),
          AnimatedContainer(
            decoration: const BoxDecoration(
                color: Color(0xFFEE4400),
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            height: (connected) ? 0 : 24,
            width: 100,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.linear,
            child: const Center(
              child: Text(
                "Offline",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          (connected)
              ? Container()
              : const SizedBox(
                  height: 10,
                ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16, 16, 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    minRadius: 30,
                    child: ClipOval(
                        child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: 90.0,
                      placeholder: (context, url) => CircularProgressIndicator(
                        backgroundColor: theme.iconColor,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      height: 90.0,
                      imageUrl: user.imageUrl,
                    )),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hey " + user.name.split(' ')[0] + '!',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: theme.textHeadingColor),
                        ),
                        Text("How are you doing today? ",
                            style: TextStyle(color: theme.textSubheadingColor)),
                      ]),
                ]),
          ),
          const SizedBox(height: 10),
          if (quote != '')
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
              child: Text(
                "\"" + quote + "\" - " + quoteAuthor,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12.0,
                    fontStyle: FontStyle.italic,
                    color: theme.textSubheadingColor),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32.0, 16, 16, 0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Hungry?",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: theme.textHeadingColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Here's what's for ${dataContainer.mess.currentMealTitle.toLowerCase()}",
                          style: TextStyle(color: theme.textSubheadingColor),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward, color: theme.iconColor),
                      onPressed: () {
                        Navigator.pushNamed(context, '/messmenu');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          scrollableMessMenu(),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(32.0, 16, 16, 0),
          //   child: Column(
          //     children: <Widget>[
          //       Row(
          //         mainAxisSize: MainAxisSize.max,
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: <Widget>[
          //           Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: <Widget>[
          //               Text(
          //                 "Wondering what's next?",
          //                 style: TextStyle(
          //                     fontSize: 18.0,
          //                     fontWeight: FontWeight.bold,
          //                     color: theme.textHeadingColor),
          //               ),
          //               Text(
          //                 "Enjoy your free time!",
          //                 style: TextStyle(color: theme.textSubheadingColor),
          //               ),
          //             ],
          //           ),
          //           IconButton(
          //             icon: Icon(
          //               Icons.arrow_forward,
          //               color: theme.iconColor.withAlpha(150),
          //             ),
          //             onPressed: () {
          //               Navigator.pushNamed(context, '/schedule')
          //                   .then((value) => setState(() {}));
          //             },
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 10),
          //     ],
          //   ),
          // ),
        ],
      ),
    ));
  }

  @override
  bool get wantKeepAlive => true;
}
