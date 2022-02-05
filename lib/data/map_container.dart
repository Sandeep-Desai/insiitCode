import 'package:insiit/global/utils/gsheet.dart';

class MapContainer {
  GSheet sheet = GSheet('1gbvHlslrNErxJzp9cgqMKgvxxRqERJm7_ZRZKiOad9o');
  Future<void> init() async {
    await sheet.initializeCache();
  }
}
