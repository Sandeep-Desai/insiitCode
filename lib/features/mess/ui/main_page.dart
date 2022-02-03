import 'package:flutter/material.dart';
import 'package:insiit/features/mess/classes/item.dart';
import 'package:insiit/features/mess/classes/slot.dart';
import 'package:insiit/global/data/constants.dart';
import 'package:insiit/global/theme/notifier.dart';

class MessMenu extends StatefulWidget {
  const MessMenu({Key? key}) : super(key: key);

  @override
  _MessMenuState createState() => _MessMenuState();
}

class _MessMenuState extends State<MessMenu> {
  Widget foodListHeader(String time, String name) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: theme.textHeadingColor),
          ),
          Text(time,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.textSubheadingColor))
        ],
      ),
    );
  }

  Widget createItemCard(List<MessItem> foodList) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: foodList.map<Widget>((MessItem item) {
          if (item.name != '-') {
            return Card(
              elevation: 0,
              color: theme.cardAccent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: ScreenSize.size.width * 0.6,
                      child: Text(
                        item.name,
                        style: TextStyle(
                            fontSize: 16.0, color: theme.textHeadingColor),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(
                            Icons.thumb_down_alt,
                          ),
                          iconSize: 20,
                          color: (item.vote == -1)
                              ? theme.downvoteColor
                              : theme.iconColorLite,
                          onPressed: () async {
                            setState(() {
                              if (item.vote == -1) {
                                item.vote = 0;
                              } else {
                                item.vote = -1;
                              }
                              // voting system to change TODO
                              dataContainer.mess.sheet.writeData([
                                [
                                  DateTime.now().toString(),
                                  DateTime.now().weekday,
                                  item.name,
                                ]
                              ], 'messFeedbackItems!A:C');
                            });
                            dataContainer.mess.storeFoodVotes();
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.thumb_up_alt,
                          ),
                          iconSize: 20,
                          color: (item.vote == 1)
                              ? theme.upvoteColor
                              : theme.iconColorLite,
                          onPressed: () async {
                            setState(() {
                              if (item.vote == 1) {
                                item.vote = 0;
                              } else {
                                item.vote = 1;
                              }

// change voting system TODO
                              dataContainer.mess.sheet.writeData([
                                [
                                  DateTime.now().toString(),
                                  DateTime.now().weekday,
                                  item.name
                                ]
                              ], 'messFeedbackItems!A:C');
                            });
                            dataContainer.mess.storeFoodVotes();
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return Container();
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: DateTime.now().weekday - 1,
      length: 7,
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.appBarColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text('Mess Menu',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: theme.textHeadingColor)),
          bottom: PreferredSize(
            child: TabBar(
              isScrollable: true,
              unselectedLabelColor: theme.textHeadingColor.withOpacity(0.3),
              indicatorColor: theme.indicatorColor,
              labelColor: theme.textHeadingColor,
              tabs: <Widget>[
                for (int i = 0; i < 7; i++) Tab(text: dayOfWeek[i + 1])
              ],
            ),
            preferredSize: const Size.fromHeight(50.0),
          ),
        ),
        body: TabBarView(
          children: [0, 1, 2, 3, 4, 5, 6].map((dayIndex) {
            return Container(
                padding: const EdgeInsets.all(0.0),
                child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(.0),
                        child: Column(
                          children: <Widget>[
                            ExpansionTile(
                              title: foodListHeader(
                                  dataContainer
                                          .mess.items[dayIndex]?.times[index] ??
                                      "",
                                  messHeadings[index]),
                              children: <Widget>[
                                createItemCard(dataContainer.mess
                                        .items[dayIndex]?.allItems[index] ??
                                    []),
                              ],
                            ),
                          ],
                        ),
                      );
                    }));
          }).toList(),
        ),
        floatingActionButton: ElevatedButton.icon(
          // color: theme.floatingColor,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(16.0),
          // ),
          onPressed: () {
            Navigator.pushNamed(context, '/messfeedback');
          },
          icon: const Icon(
            Icons.rate_review,
            color: Colors.white,
          ),
          label: const Text(
            'Review',
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
