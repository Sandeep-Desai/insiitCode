import 'dart:developer';

import 'package:insiit/data/general_data_container.dart';
import 'package:insiit/data/mess_container.dart';
import 'package:insiit/global/classes/user.dart';

// dataContainer.mess.messItems
class DataContainer {
  GeneralData generalData = GeneralData();
  MessContainer mess = MessContainer();
  User user = User();
  String debugTag = 'DataContainer';
  Future<void> init() async {
    await generalData.init();
    await mess.init();
    log('Data Loaded', name: debugTag);
  }
}
