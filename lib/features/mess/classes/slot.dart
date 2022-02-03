import 'package:insiit/features/mess/classes/item.dart';

class MessDay {
  bool isExpanded;
  int day;
  List<String> times = [];
  List<MessItem> breakfast;
  List<MessItem> lunch;
  List<MessItem> dinner;
  List<MessItem> snacks;
  late List<List<MessItem>> allItems;

  MessDay({
    this.isExpanded = false,
    required this.day,
    required this.breakfast,
    required this.times,
    required this.lunch,
    required this.dinner,
    required this.snacks,
  }) {
    allItems = [breakfast, lunch, dinner, snacks];
  }
}
