import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class GeneralData {
  String debugTag = 'GeneralData';
  bool darkMode = false;
  late var quotes = [];
  late Box box;
  Future<void> init() async {
    await Hive.openBox('genData').then((value) async {
      box = value;
      await loadData();
    });
  }

  Future<dynamic> loadQuotes() async {
    var ret = [];
    log('Loading quotes', name: debugTag);
    http.Response response =
        await http.get(Uri.parse('https://type.fit/api/quotes'));
    if (response.statusCode == 200) {
      ret = jsonDecode(response.body);
    }
    box.put('quotes', quotes);
    return ret;
  }

  Future<void> loadData() async {
    log('Loading data', name: debugTag);
    darkMode = box.get('darkMode') ?? false;
    quotes = box.get('quotes') ?? await loadQuotes();
  }

  void saveData() {
    log('Saving data', name: debugTag);
    box.put('darkMode', darkMode);
  }
}
