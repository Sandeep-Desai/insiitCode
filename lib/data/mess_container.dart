import 'dart:developer';

import 'package:hive/hive.dart';
import 'package:insiit/features/mess/classes/item.dart';
import 'package:insiit/features/mess/classes/slot.dart';
import 'package:insiit/global/utils/gsheet.dart';

class MessContainer {
  GSheet sheet = GSheet('10NzrujjTXV0n0DnZXWJDaRHi1AGgMWhtK2quVa_jOrU');
  String debugTag = 'Mess';
  late Box cache;
  Map<int, MessDay> items = {};
  Map<String, int> foodVotes = {};
  List<MessItem> currentMeal = [];
  void getData({forceRefresh = false}) async {
    loadMessData(forceRefresh: forceRefresh);
    loadFoodVotesData();
  }

  Future<void> init() async {
    log('Loading Mess', name: debugTag);
    cache = await Hive.openBox('mess');
    await sheet.initializeCache();
    getData();
  }

  // open app, load from cache, request new data, update cache.

  Future<void> loadMessData({forceRefresh = false}) async {
    sheet.getData('Sheet6!A:G', forceRefresh: forceRefresh).listen((cache) {
      var data = [];
      for (int i = 0; i < cache.length; i++) {
        data.add(cache[i]);
      }
      int nBreakfast = (data[0][0] is int) ? data[0][0] : int.parse(data[0][0]);
      int nLunch = (data[0][1] is int) ? data[0][1] : int.parse(data[0][1]);
      int nSnack = (data[0][2] is int) ? data[0][2] : int.parse(data[0][2]);
      int nDinner = (data[0][3] is int) ? data[0][3] : int.parse(data[0][3]);
      data.removeAt(0);
      makeMessList(data, nBreakfast, nLunch, nSnack, nDinner);

      selectMeal();
    });
  }

  void makeMessList(
      List data, int nBreakfast, int nLunch, int nSnack, int nDinner) {
    data.removeAt(0);
    data.removeAt(0);
    data.removeAt(0);

    for (int i = 0; i < 7; i++) {
      List<String> times = [];

      List<MessItem> breakfast = [];
      times.add(data[0][i * 4]);
      for (int j = 1; j < nBreakfast; j++) {
        breakfast.add(MessItem(
          name: data[j][i * 4],
          calories: data[j][i * 4 + 1],
          glutenFree: data[j][i * 4 + 2],
          imageUrl: data[j][i * 4 + 3],
        ));
      }

      List<MessItem> lunch = [];
      times.add(data[0][i * 4 + nBreakfast]);
      for (int j = 1; j < nLunch; j++) {
        lunch.add(MessItem(
          name: data[j][i * 4 + nBreakfast],
          calories: data[j][i * 4 + nBreakfast + 1],
          glutenFree: data[j][i * 4 + nBreakfast + 2],
          imageUrl: data[j][i * 4 + nBreakfast + 3],
        ));
      }

      List<MessItem> snack = [];
      times.add(data[0][i * 4 + nBreakfast + nLunch]);
      for (int j = 1; j < nSnack; j++) {
        snack.add(MessItem(
          name: data[j][i * 4 + nBreakfast + nLunch],
          calories: data[j][i * 4 + nBreakfast + nLunch + 1],
          glutenFree: data[j][i * 4 + nBreakfast + nLunch + 2],
          imageUrl: data[j][i * 4 + nBreakfast + nLunch + 3],
        ));
      }

      List<MessItem> dinner = [];
      times.add(data[0][i * 4 + nBreakfast + nLunch + nSnack]);
      for (int j = 1; j < nDinner; j++) {
        dinner.add(MessItem(
          name: data[j][i * 4 + nBreakfast + nLunch + nSnack],
          calories: data[j][i * 4 + nBreakfast + nLunch + nSnack + 1],
          glutenFree: data[j][i * 4 + nBreakfast + nLunch + nSnack + 2],
          imageUrl: data[j][i * 4 + nBreakfast + nLunch + nSnack + 3],
        ));
      }

      items[i] = MessDay(
          day: i,
          breakfast: breakfast,
          times: times,
          dinner: dinner,
          lunch: lunch,
          snacks: snack);
    }
  }

  void loadFoodVotesData() {
    Map<String, int> data = cache.get('foodvotes') as Map<String, int>;
    for (int i = 0; i < 7; i++) {
      for (MessDay day in items[i] as List<MessDay>) {
        for (MessItem item in day.breakfast) {
          item.vote = data[item.name] ?? 0;
        }
      }
    }
  }

  void storeFoodVotes() {
    cache.put('foodvotes', foodVotes);
  }

  void selectMeal() {
    int day = DateTime.now().weekday - 1;

    int hour = DateTime.now().hour;
    if (hour >= 4 && hour <= 10.5) {
      currentMeal = items[day]!.breakfast;
    } else if (hour > 10.5 && hour <= 14.5) {
      currentMeal = items[day]!.lunch;
    } else if (hour > 14.5 && hour < 18) {
      currentMeal = items[day]!.snacks;
    } else {
      currentMeal = items[day]!.dinner;
    }
  }
}
