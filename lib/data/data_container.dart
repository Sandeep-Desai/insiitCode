import 'dart:developer';

import 'package:insiit/data/general_data_container.dart';
import 'package:insiit/data/map_container.dart';
import 'package:insiit/data/mess_container.dart';
import 'package:insiit/global/classes/user.dart';

// dataContainer.mess.messItems
class DataContainer {
  GeneralData generalData = GeneralData();
  MessContainer mess = MessContainer();
  MapContainer map = MapContainer();

  User user = User();
  String debugTag = 'DataContainer';
  Future<void> init() async {
    await generalData.init();
    await mess.init();
    await map.init();
    log('Data Loaded', name: debugTag);
  }
}
