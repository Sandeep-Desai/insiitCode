import 'package:flutter/material.dart';

List keywordList = [];
List locationList = [];

class CustomSearch extends SearchDelegate<String> {
  // @override
  // ThemeData appBarTheme(BuildContext context) {
  //   assert(context != null);
  //   final ThemeData theme = Theme.of(context);
  //   assert(theme != null);
  //   return theme.copyWith(
  //     inputDecorationTheme: InputDecorationTheme(
  //           hintStyle: TextStyle(color: theme.primaryTextTheme.headline6.color.withOpacity(0.6))),
  //       primaryColor: theme.primaryColor,
  //       primaryIconTheme: theme.primaryIconTheme,
  //       primaryColorBrightness: theme.primaryColorBrightness,
  //       primaryTextTheme: theme.primaryTextTheme,
  //       textTheme: theme.textTheme.copyWith(
  //           headline6: theme.textTheme.headline6
  //               .copyWith(color: theme.primaryTextTheme.headline6.color))
  //   );
  // }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, "null");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    //DONT REMOVE
    throw UnimplementedError();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(15),
          height: 425,
          decoration: const BoxDecoration(
            color: Colors.white10,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: const <Widget>[
                Image(
                  image: AssetImage('assets/images/map_search.png'),
                ),
                Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: Text(
                    "This location search is powered by a comprehensive list of keywords. For example, if you search 'food', the dining hall and canteens will come up as suggestions.",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      final suggestions = locationList
          .where((p) => keywordList[locationList.indexOf(p)]
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
      return ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: () {
            close(context, locationList.indexOf(suggestions[index]).toString());
          },
          leading: const Icon(Icons.location_city),
          title: Text(suggestions[index]),
        ),
        itemCount: suggestions.length,
      );
    }
  }
}
