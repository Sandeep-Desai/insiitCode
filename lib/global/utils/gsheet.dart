import 'dart:developer';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:hive/hive.dart';
import 'package:insiit/global/data/credentials.dart';

class GSheet {
  //range in the form "sheetname!A:C" A:C is range of columns
  //data returned in the form of [[row], [row], [row], [row]]
  final scopes = [sheets.SheetsApi.spreadsheetsScope];
  String debugTag = 'Gsheet';
  String spreadSheetID;
  late Box cache;
  bool refreshNeeded = false;
  GSheet(this.spreadSheetID);
  Future<void> initializeCache() async {
    cache = await Hive.openBox(spreadSheetID);
    debugTag += "|" + spreadSheetID;
    log('Loading sheet', name: debugTag);
  }

  Future<void> forceClearCache() async {
    await cache.deleteFromDisk();
    cache = await Hive.openBox(spreadSheetID);
  }

  Future writeData(var data, String range) async {
    await auth.clientViaServiceAccount(credentials, scopes).then((client) {
      auth
          .obtainAccessCredentialsViaServiceAccount(credentials, scopes, client)
          .then((auth.AccessCredentials cred) {
        SheetsApi api = SheetsApi(client);
        ValueRange vr = sheets.ValueRange.fromJson({
          "values": data //data is [[row1],[row2], ...]
        });
        api.spreadsheets.values
            .append(vr, spreadSheetID, range, valueInputOption: 'USER_ENTERED')
            .then((AppendValuesResponse r) {
          client.close();
        });
      });
    });
  }

  bool isRefreshRequired() {
    if (refreshNeeded != null) {
      return refreshNeeded;
    }
    String lastRetrieved = cache.get('lastAccessed');
    if (lastRetrieved == null) {
      return true;
    }
    final lastAccessedDate = DateTime.parse(lastRetrieved);
    final now = DateTime.now();
    final difference = now.difference(lastAccessedDate).inDays;

    if (difference > 0) {
      refreshNeeded = true;
      log("It's been $difference days since last refreshed.", name: debugTag);
    } else {
      refreshNeeded = false;
      log("Sheet refresh not needed", name: debugTag);
    }

    return refreshNeeded;
  }

  Stream<List> getData(String range, {forceRefresh = false}) async* {
    List returnval;
    List data = cache.get(range) ?? [];
    if (data.isNotEmpty) {
      log("Retrieved ${data.length} x ${data[0].length} from cache",
          name: debugTag);
      yield data;
    }

    if (forceRefresh || data.isEmpty || isRefreshRequired()) {
      log("Getting data at $range from internet", name: debugTag);
      returnval = await getDataOnline(range);

      cache.put(range, returnval);
      cache.put('lastAccessed', DateTime.now().toString());
      log("Retrieved ${returnval.length} x ${returnval[0].length} from internet",
          name: debugTag);
      yield returnval;
    }
  }

  Future<List> getDataOnline(String range) async {
    var returnval;
    await auth
        .clientViaServiceAccount(credentials, scopes)
        .then((client) async {
      await auth
          .obtainAccessCredentialsViaServiceAccount(credentials, scopes, client)
          .then((auth.AccessCredentials cred) async {
        SheetsApi api = SheetsApi(client);
        await api.spreadsheets.values.get(spreadSheetID, range).then((qs) {
          returnval = qs.values;
        });
      });
    });
    return returnval;
  }

  Future updateData(var data, String range) async {
    await auth.clientViaServiceAccount(credentials, scopes).then((client) {
      auth
          .obtainAccessCredentialsViaServiceAccount(credentials, scopes, client)
          .then((auth.AccessCredentials cred) {
        SheetsApi api = SheetsApi(client);

        ValueRange vr = sheets.ValueRange.fromJson({"values": data});
        api.spreadsheets.values
            .update(vr, spreadSheetID, range, valueInputOption: 'USER_ENTERED')
            .then((UpdateValuesResponse r) {
          log("Updated data at $range", name: debugTag);
          client.close();
        });
      });
    });
  }
}
