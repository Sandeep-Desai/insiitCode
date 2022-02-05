import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapInfoWindow {
  String imagePath;
  LatLng location;
  String locationName;
  String timing;
  String descriptionOne;
  String descriptionTwo;

  MapInfoWindow(
      {required this.imagePath,
      required this.location,
      required this.locationName,
      required this.timing,
      required this.descriptionOne,
      required this.descriptionTwo});
}
